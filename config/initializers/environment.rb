# frozen_string_literal: true

Rails.application.config.x.twitter.api_key = ENV.fetch('TWITTER_API_KEY', nil)
Rails.application.config.x.twitter.api_secret = ENV.fetch('TWITTER_API_SECRET', nil)
Rails.application.config.x.disqus.public_key = ENV.fetch('DISQUS_PUBLIC_KEY', nil)
Rails.application.config.x.disqus.secret_key = ENV.fetch('DISQUS_SECRET_KEY', nil)
Rails.application.config.x.paddle.vendor_id = ENV.fetch('PADDLE_VENDOR_ID', nil)
Rails.application.config.x.paddle.vendor_auth = ENV.fetch('PADDLE_VENDOR_AUTH', nil)
