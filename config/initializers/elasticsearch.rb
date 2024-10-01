puts "Elasticsearch URL: #{ENV['ELASTICSEARCH_URL'] || 'Not set'}"

Searchkick.client = Elasticsearch::Client.new(
  url: ENV['ELASTICSEARCH_URL'] || 'http://elasticsearch:9200',
  retry_on_failure: true,
  transport_options: { request: { timeout: 250 } }
)
