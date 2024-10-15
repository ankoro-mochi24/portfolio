require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request

  # テストの前にSearchkickのコールバックを無効化
  config.before(:each) do
    Searchkick.disable_callbacks
  end

  # テストの後にSearchkickのコールバックを再度有効化し、再インデックスを実行
  config.after(:each) do
    Searchkick.enable_callbacks
    Recipe.reindex
    Foodstuff.reindex
  end

  # テスト終了後にインデックスを削除する処理
  config.after(:suite) do
    Recipe.search_index.delete if Recipe.search_index.exists?
    Foodstuff.search_index.delete if Foodstuff.search_index.exists?
  end
end
