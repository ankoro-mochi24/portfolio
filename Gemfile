source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"
gem "rails", "~> 7.0.8", ">= 7.0.8.4"

gem "sprockets-rails"
gem "mysql2", "~> 0.5"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem 'sassc'                    # scss
gem 'devise'                   # ユーザー認証
gem 'carrierwave'              # 画像保存
gem 'i18n'                     # 国際化対応全般
gem 'devise-i18n'              # deviceの国際化対応
gem 'searchkick'               # 検索
gem 'elasticsearch', '~> 7.0'  # Elasticsearchとの連携
gem 'faker'                    # 疑似データ
gem 'kaminari'                 # ページネーション
