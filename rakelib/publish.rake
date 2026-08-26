# frozen_string_literal: true

require_relative "../lib/uchi/version"
require_relative "publish"

CHANGELOG_PATH = File.expand_path("../CHANGELOG.md", __dir__)

def built_gem_path
  File.expand_path("../pkg/uchi-#{Uchi::VERSION}.gem", __dir__)
end

def changelog_entry
  changelog = Uchi::Publish::Changelog.new(path: CHANGELOG_PATH)
  entry = changelog.entry_for(version: Uchi::VERSION)

  if entry.nil?
    warn "No changelog entry found for #{Uchi::VERSION} in CHANGELOG.md. Releasing without release notes."
  elsif changelog.unreleased?(version: Uchi::VERSION)
    warn "No '## #{Uchi::VERSION}' heading in CHANGELOG.md, using the Unreleased section instead."
  end

  entry
end

# Uchi is released to the Uchi Mothership, not to rubygems.org, so replace
# Bundlers push task with one that uploads to our own gem server. The rest of
# `rake release` (guarding against a dirty checkout, tagging, pushing the tag)
# is left alone.
Rake::Task["release:rubygem_push"].clear

# Fail before tagging and pushing to git if we have no way of authenticating
# against the Mothership.
Rake::Task["release"].prerequisites.unshift("release:guard_token")

namespace :release do
  desc "Show the release notes that will be published with #{Uchi::VERSION}"
  task :changelog do
    puts changelog_entry || "(none)"
  end

  desc "Check that we have an API token for the Uchi Mothership"
  task :guard_token do
    Uchi::Publish.token
  rescue Uchi::Publish::Error => error
    abort error.message
  end

  desc "Push the built gem to the Uchi Mothership"
  task :rubygem_push do
    unless File.exist?(built_gem_path)
      abort "#{built_gem_path} does not exist. Run `rake build` first."
    end

    publisher = Uchi::Publish::Publisher.new(
      changelog: changelog_entry,
      host: Uchi::Publish::HOST,
      path: built_gem_path,
      token: Uchi::Publish.token,
      version: Uchi::VERSION
    )

    puts "Pushing uchi #{Uchi::VERSION} to #{Uchi::Publish::HOST}..."
    message = publisher.publish!
    puts message.empty? ? "Pushed uchi #{Uchi::VERSION}." : message
  rescue Uchi::Publish::Error => error
    abort error.message
  end
end
