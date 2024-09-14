Searchkick.client = Elasticsearch::Client.new(
  hosts: [ENV['SEARCHBOX_URL'] || 'http://localhost:9200'],  # HerokuのURLがない場合はローカルElasticsearchを使用
  retry_on_failure: true,  # 失敗時のリトライを有効にする
  transport_options: { request: { timeout: 250 } }  # リクエストのタイムアウトを250秒に設定
)