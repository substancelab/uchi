// This is main application javascript file for Uchi. It gets bundled by esbuild
// into vendor/uchi/app/assets/javascripts/uchi/application.js

import "@hotwired/turbo-rails"

import { Application } from '@hotwired/stimulus'
import Dropdown from '@stimulus-components/dropdown'

import BelongsTo from './controllers/fields/belongs_to_controller.js'
import HasMany from './controllers/fields/has_many_controller.js'

// Start Stimulus and register components
const application = Application.start()
application.register('belongs-to', BelongsTo)
application.register('dropdown', Dropdown)
application.register('has-many', HasMany)

if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
  document.documentElement.classList.add('dark')
}
