puts "Elasticsearch URL: #{ENV['BONSAI_URL'] || 'Not set'}"

Searchkick.client = Elasticsearch::Client.new(
#  hosts: [ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'],
  url: ENV['BONSAI_URL'],  # ここを 'url' に変更
  retry_on_failure: true,  # 失敗時のリトライを有効にする
  transport_options: { request: { timeout: 250 } }  # リクエストのタイムアウトを250秒に設定
)
