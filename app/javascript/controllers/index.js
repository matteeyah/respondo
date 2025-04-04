// Import and register all your controllers from the importmap under controllers/*

import { application } from 'controllers/application'

// Load custom controllers.
import { Alert, Dropdown, Slideover, Tabs, Toggle } from 'tailwindcss-stimulus-components'

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
eagerLoadControllersFrom('controllers', application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

// Register custom controllers.
application.register('alert', Alert)
application.register('dropdown', Dropdown)
application.register('slideover', Slideover)
application.register('tabs', Tabs)
application.register('toggle', Toggle)
