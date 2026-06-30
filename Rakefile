# frozen_string_literal: true

require "bundler/gem_tasks"
require "bundler/setup"
require "standard/rake"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

namespace :docs do
  desc "Build documentation using Docyard"
  task :build do
    sh "bundle exec docyard build"
  end

  desc "Serve documentation locally with live reloading"
  task :serve do
    sh "bundle exec docyard serve"
  end
end

namespace :herb do
  desc "Automatically fix Herb offenses in erb files"
  task :fix do
    sh "npm run herb:lint -- --fix"
  end

  desc "Lint erb files using Herb"
  task :lint do
    sh "npm run herb:lint"
  end
end

task default: ["app:test", "standard", "herb:lint"]
