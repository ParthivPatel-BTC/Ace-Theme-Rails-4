json.array!(@products) do |product|
  json.extract! product, :id, :name, :category_id, :price, :delivery_date, :description
  json.url product_url(product, format: :json)
end
