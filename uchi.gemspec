# frozen_string_literal: true

require_relative "lib/uchi/version"

Gem::Specification.new do |spec|
  spec.name = "uchi"
  spec.version = Uchi::VERSION
  spec.authors = ["Jakob Skjerning"]
  spec.email = ["jakob@mentalized.net"]

  spec.summary = "Some automated admin stuff for Rails apps"
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/substancelab/uchi"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/substancelab/uchi"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[app/ bin/ config/ lib/ Gemfile MIT-LICENSE Rakefile README.md .gitignore .standard.yml])
    end
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "flowbite-components", ">= 0.1.2"
  spec.add_dependency "pagy", ">= 43.0.0.rc1"
  spec.add_dependency "rails", ">= 7.2"
  spec.add_dependency "turbo-rails"
end
