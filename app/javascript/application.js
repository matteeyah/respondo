// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import 'popper'
import 'bootstrap'

import '@hotwired/turbo-rails'

const tooltipTriggerList = document.querySelectorAll('[data-bs-tooltip=true]')
const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl)) // eslint-disable-line
