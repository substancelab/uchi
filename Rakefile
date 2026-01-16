# frozen_string_literal: true

require "bundler/gem_tasks"
require "bundler/setup"
require "standard/rake"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

namespace :herb do
  task :lint do
    sh "npm run herb:lint"
  end
end

task default: ["app:test", "standard", "herb:lint"]
