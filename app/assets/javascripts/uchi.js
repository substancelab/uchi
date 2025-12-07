// This is main application javascript file for Uchi. It gets bundled by esbuild
// into vendor/uchi/app/assets/javascripts/uchi/application.js

import "@hotwired/turbo-rails"

import { Application } from '@hotwired/stimulus'
import Dropdown from '@stimulus-components/dropdown'

// Start Stimulus and register components
const application = Application.start()
application.register('dropdown', Dropdown)
