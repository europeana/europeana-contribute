# frozen_string_literal: true

CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
    region:                ENV['S3_REGION'],
    host:                  ENV['S3_HOST'],
    endpoint:              ENV['S3_ENDPOINT'],
    path_style:            ENV['S3_PATH_STYLE'].to_i == 1
  }
  config.fog_directory  = ENV['S3_BUCKET']
  config.fog_public     = true
  config.fog_attributes = { cache_control: "public, max-age=#{365.day.to_i}" }
end
