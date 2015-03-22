json.array!(@manuscripts) do |manuscript|
  json.extract! manuscript, :id, :title, :shelfmark, :url
  json.url manuscript_url(manuscript, format: :json)
end
