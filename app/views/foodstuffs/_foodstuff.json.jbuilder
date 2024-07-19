json.extract! foodstuff, :id, :name, :price, :description, :link, :image, :created_at, :updated_at
json.url foodstuff_url(foodstuff, format: :json)
