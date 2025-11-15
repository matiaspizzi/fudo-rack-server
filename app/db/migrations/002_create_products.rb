Sequel.migration do
  change do
    create_table(:products) do
      primary_key :id
      String :name, null: false
      String :description
      Float :price, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
