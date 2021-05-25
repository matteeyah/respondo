# frozen_string_literal: true

Rails.application.config.twitter.api_key = ENV['TWITTER_API_KEY']
Rails.application.config.twitter.api_secret = ENV['TWITTER_API_SECRET']
Rails.application.config.disqus.public_key = ENV['DISQUS_PUBLIC_KEY']
Rails.application.config.disqus.secret_key = ENV['DISQUS_SECRET_KEY']
Rails.application.config.paddle.vendor_id = ENV['PADDLE_VENDOR_ID']
Rails.application.config.paddle.vendor_auth = ENV['PADDLE_VENDOR_AUTH']
