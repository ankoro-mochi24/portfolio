source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'
gem "rails", "~> 7.0.8", ">= 7.0.8.4"

gem "sprockets-rails"
gem 'pg'
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem 'dotenv-rails'                 # 環境変数を設定するためのGem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]  # デバッグツール
  gem 'rspec-rails', '~> 5.0'
end

group :development do
  gem "web-console"                  # Railsの開発環境で使用するインタラクティブコンソール
  gem "mailcatcher"                  # 開発環境でのメール送信テスト用ツール
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false     # RSpec用のルールセット
  gem 'rubocop-factory_bot', require: false # FactoryBot用のルールセット
end

group :test do
  gem "capybara"                     # 統合テスト用のDSL
  gem "selenium-webdriver"           # ブラウザを操作するためのWebDriver
  gem 'factory_bot_rails'            # テストデータの生成
  gem 'faker'                        # 疑似データ
  gem 'shoulda-matchers', '~> 5.0'
  gem 'webmock'
end

gem 'sassc'                    # scss
gem 'devise'                   # ユーザー認証
gem 'carrierwave'              # 画像保存
gem 'fog-aws'                  # S3との連携
gem 'i18n'                     # 国際化対応全般
gem 'devise-i18n'              # deviceの国際化対応
gem 'i18n-tasks'               # 未使用のキーを自動的に確認
gem 'searchkick', '~> 4.4'     # 検索
gem 'elasticsearch', '~> 7.6.0'# Elasticsearchとの連携
gem 'kaminari'                 # ページネーション
gem 'kaminari-i18n'            # ページネーションの国際化対応
gem 'httparty'                 # HTTPリクエスト
