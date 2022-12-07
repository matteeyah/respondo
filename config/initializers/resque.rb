# frozen_string_literal: true

Resque.redis = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')
