# frozen_string_literal: true

require_relative "lib/uchi/version"

Gem::Specification.new do |spec|
  spec.name = "uchi"
  spec.version = Uchi::VERSION
  spec.authors = ["Jakob Skjerning"]
  spec.email = ["jakob@substancelab.com"]

  spec.summary = "Build usable and extensible admin panels for your Ruby on Rails application in minutes."
  spec.description = "Level up your scaffolds with a modern admin backend framework, designed for Rails developers who demand both beauty, functionality, and extensibility. Uchi provides a set of components and conventions for creating user interfaces that are both powerful and easy to use."
  spec.homepage = "https://www.uchiadmin.com/"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["changelog_uri"] = "https://github.com/substancelab/uchi/blob/main/CHANGELOG.md"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/substancelab/uchi"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ config/ Gemfile MIT-LICENSE Rakefile README.md .gitignore .standard.yml])
    end
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.2"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "view_component", ">= 4.0"
end
