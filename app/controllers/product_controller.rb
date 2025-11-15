require "json"
require_relative "../models/product"

class ProductController
  def index(req)
    LOG.info "Fetching paginated products"

    offset = (req.params["offset"] || 0).to_i
    page_size = [(req.params["page_size"] || 10).to_i, 30].min

    if offset.negative? || page_size <= 0
      LOG.error "Invalid pagination parameters: offset=#{offset}, page_size=#{page_size}"
      return [400, { "Content-Type" => "application/json" }, [{ error: "Invalid pagination parameters" }.to_json]]
    end

    products = Product.limit(page_size).offset(offset).map(&:to_hash)
    total_count = Product.count

    LOG.info "Returning #{products.size} products (offset=#{offset}, page_size=#{page_size})"

    [200, { "Content-Type" => "application/json" }, [{
      products: products,
      pagination: {
        offset: offset,
        page_size: page_size,
        total_count: total_count
      }
    }.to_json]]
  end

  def show(req)
    id = req.path_info.split("/").last.to_i
    LOG.info "Fetching product with ID: #{id}"

    product = Product.first(id: id)
    return [404, { "Content-Type" => "application/json" }, [{ error: "not_found" }.to_json]] unless product

    [200, { "Content-Type" => "application/json" }, [product.to_json]]
  rescue StandardError => e
    LOG.error "Error fetching product: #{e.message}"
    [500, { "Content-Type" => "application/json" }, [{ error: "Internal server error" }.to_json]]
  end

  def create(req)
    data = JSON.parse(req.body.read)
    name = data["name"]

    if name.nil? || name.strip.empty?
      LOG.error "Invalid product name: #{name.inspect}"
      return [400, { "Content-Type" => "application/json" }, [{ error: "Invalid product name" }.to_json]]
    end

    Thread.new do
      begin
        sleep 5
        Product.create(name: name)
        LOG.info "Product '#{name}' created successfully"
      rescue StandardError => e
        LOG.error "Error creating product: #{e.message}"
      end
    end

    LOG.info "Product creation for '#{name}' scheduled asynchronously"
    [202, { "Content-Type" => "application/json" }, [{ message: "product will be created asynchronously" }.to_json]]
  rescue JSON::ParserError
    LOG.error "Invalid JSON body in create request"
    [400, { "Content-Type" => "application/json" }, [{ error: "Invalid JSON" }.to_json]]
  end
end
