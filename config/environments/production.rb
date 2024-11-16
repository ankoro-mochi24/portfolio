require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV.fetch('SMTP_ADDRESS', nil),  # メールサーバーのアドレス
    port:                 ENV.fetch('SMTP_PORT', nil),     # メールサーバーのポート
    domain:               ENV.fetch('SMTP_DOMAIN', nil),   # ドメイン名
    user_name:            ENV.fetch('SMTP_USERNAME', nil), # SMTP認証用のユーザー名
    password:             ENV.fetch('SMTP_PASSWORD', nil), # SMTP認証用のパスワード
    authentication:       :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.default_url_options = { host: 'yourdomain.com', protocol: 'https' }
  
  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.assets.compile = false

  config.active_storage.service = :local

  config.log_level = :info

  config.log_tags = [ :request_id ]

  config.action_mailer.perform_caching = false

  config.i18n.fallbacks = true

  config.active_support.report_deprecations = false

  config.log_formatter = Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
