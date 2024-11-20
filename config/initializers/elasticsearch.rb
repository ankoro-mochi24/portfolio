# ログに表示するためのElasticsearchのURLを確認
elasticsearch_url = ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL'] || 'http://elasticsearch:9200'
Rails.logger.debug { "Elasticsearch URL: #{elasticsearch_url}" }

# Searchkickクライアントの設定
Searchkick.client = Elasticsearch::Client.new(
  url: elasticsearch_url,
  retry_on_failure: true,
  transport_options: { request: { timeout: 250 } }
)
