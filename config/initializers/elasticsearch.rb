Searchkick.client = Elasticsearch::Client.new(
  hosts: ["http://elasticsearch:9200"],  # Elasticsearchのホスト設定
  retry_on_failure: true,  # 失敗時のリトライを有効にする
  transport_options: { request: { timeout: 250 } }  # リクエストのタイムアウトを250秒に設定
)