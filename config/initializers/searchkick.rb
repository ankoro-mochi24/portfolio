Rails.application.config.after_initialize do
  begin
    Recipe.reindex unless Recipe.searchkick_index.exists?
    Foodstuff.reindex unless Foodstuff.searchkick_index.exists?
  rescue => e
    Rails.logger.error "Elasticsearch index creation failed: #{e.message}"
  end
end
