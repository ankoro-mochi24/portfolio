require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
      region:                ENV.fetch('AWS_REGION', nil),
    }
    config.fog_directory  = ENV.fetch('S3_BUCKET_NAME', nil)
    config.fog_public     = false  # プライベートにしたい場合はfalse
    config.storage        = :fog
  else
    config.storage = :file  # ローカル環境ではファイルシステムに保存
  end
end
