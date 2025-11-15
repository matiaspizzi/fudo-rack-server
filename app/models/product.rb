require_relative "../db/sequel"

class Product < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence :name
  end

  def to_hash
    {
      id: self.id,
      name: self.name,
      created_at: self.created_at,
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end
end
