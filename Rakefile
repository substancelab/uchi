# frozen_string_literal: true

require "bundler/gem_tasks"
require "bundler/setup"
require "standard/rake"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

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
  desc "Format erb files using Herb"
  task :format do
    sh "npm run herb:format"
  end

  namespace :format do
    desc "Check if erb files are formatted correctly"
    task :check do
      sh "npm run herb:format:check"
    end
  end

  desc "Automatically fix Herb offenses in erb files"
  task :fix do
    sh "npm run herb:lint -- --fix"
  end

  desc "Lint erb files using Herb"
  task :lint do
    sh "npm run herb:lint"
  end
end

task default: ["app:test", "standard", "herb:lint", "herb:format:check"]
