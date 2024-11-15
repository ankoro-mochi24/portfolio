# RSpecでRailsのテストを実行するための設定をまとめたファイル
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# WebMockの設定を追加
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true, allow: 'elasticsearch:9200') # localhostやElasticsearchを除き、インターネットへ自動的に接続することを防ぐ

# Eager load 設定
Rails.application.eager_load! if Rails.env.test? # テストのとき、使うファイルをすべて最初に読み込む

begin
  ActiveRecord::Migration.maintain_test_schema! # テスト用のデータベースが最新の状態か確認
rescue ActiveRecord::PendingMigrationError => e # 最新の状態でない場合
  puts e.to_s.strip # エラー内容を見やすく表示
  exit 1 # テストを停止
end

# Shoulda Matchersを設定して、RSpecとRailsで便利なマッチャーを使えるようにする
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec # RSpecをShoulda Matchersと連携するテストフレームワークとして設定。基本的なShoulda Matchersを利用できるようにする
    with.library :rails # Rails特有の機能（バリデーションやアソシエーション）をテストするShoulda Matchersを有効にする
  end
end

RSpec.configure do |config|
  config.fixture_path = Rails.root.join("spec/fixtures").to_s # テスト用データの保存場所を指定
  config.use_transactional_fixtures = true # テストごとにデータをリセット
  config.infer_spec_type_from_file_location! # ファイルパスからテストタイプを自動判定
  config.filter_rails_from_backtrace! # Rails内部の不要なエラーログを省略

  config.include FactoryBot::Syntax::Methods # FactoryBotのメソッドを直接使えるようにする
  config.include Devise::Test::IntegrationHelpers, type: :request # リクエストテストでDeviseのログイン機能を使用可能にする

  # テスト(itブロック毎)の前に実行
  config.before(:each) do
    Searchkick.disable_callbacks # Searchkickの自動インデックス更新を一時的に無効化し、テスト処理を高速化
  end

  # テスト(itブロック毎)の後に実行
  config.after(:each) do
    Searchkick.enable_callbacks # Searchkickの自動インデックス更新を有効化
    Recipe.reindex # Recipeのレコードを検索機能に反映
    Foodstuff.reindex # Foodstuffのレコードを検索機能に反映
  end

  # 全テスト終了後に実行
  config.after(:suite) do
    Recipe.search_index.delete if Recipe.search_index.exists? # Recipeの検索データがあれば削除する
    Foodstuff.search_index.delete if Foodstuff.search_index.exists? # Foodstuffの検索データがあれば削除する
  end
end
