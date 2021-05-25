# frozen_string_literal: true

Rails.application.config.x.twitter.api_key = ENV['TWITTER_API_KEY']
Rails.application.config.x.twitter.api_secret = ENV['TWITTER_API_SECRET']
Rails.application.config.x.disqus.public_key = ENV['DISQUS_PUBLIC_KEY']
Rails.application.config.x.disqus.secret_key = ENV['DISQUS_SECRET_KEY']
Rails.application.config.x.paddle.vendor_id = ENV['PADDLE_VENDOR_ID']
Rails.application.config.x.paddle.vendor_auth = ENV['PADDLE_VENDOR_AUTH']
