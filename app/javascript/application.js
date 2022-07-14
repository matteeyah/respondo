// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// This is a hack to make popper work with importmap
/* eslint-disable import/first */
window.process = { env: {} }
import '@popperjs/core'
import 'bootstrap'

import '@hotwired/turbo-rails'

import 'controllers'
/* eslint-enable import/first */
