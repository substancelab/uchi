# frozen_string_literal: true

require "rubygems/package"
require "tmpdir"

# Gem::Package#extract_files shells out to FileUtils.mkdir_p internally
# without requiring it itself, so this is needed even though nothing below
# calls FileUtils directly.
require "fileutils"

module Uchi
  # Development-only support code for verifying a release before it goes
  # out. This file lives outside lib/ on purpose: it is not part of the
  # released gem.
  module Release
    Error = Class.new(StandardError)

    # Confirms that the gem we are about to release actually works once
    # packaged, not just when run straight from this checkout.
    #
    # config/routes.rb went missing from a released gem once (it was never
    # added to spec.files) without any test in this repo noticing, because
    # the dummy app bundles "uchi" as a path gem and so always reads
    # app/lib/config straight off disk -- it never sees what `gem build`
    # actually ships. This extracts the exact file set the built .gem
    # contains, points the dummy app's Gemfile at that instead of this
    # checkout, and runs its test suite against it. Gemfile and Gemfile.lock
    # are restored afterwards regardless of outcome.
    class DummyAppVerifier
      ROOT = File.expand_path("..", __dir__)
      GEMFILE_PATH = File.join(ROOT, "Gemfile")
      LOCKFILE_PATH = "#{GEMFILE_PATH}.lock"
      GEMSPEC_LINE = /^gemspec$/

      def initialize(gem_path:)
        @gem_path = gem_path
      end

      def verify!
        original_gemfile = File.read(GEMFILE_PATH)
        original_lockfile = File.read(LOCKFILE_PATH)

        Dir.mktmpdir("uchi-release-verify") do |packaged_gem_dir|
          Gem::Package.new(gem_path).extract_files(packaged_gem_dir)
          point_gemfile_at(packaged_gem_dir)
          bundle_install!
          run_dummy_test_suite!
        end
      ensure
        File.write(GEMFILE_PATH, original_gemfile) if original_gemfile
        File.write(LOCKFILE_PATH, original_lockfile) if original_lockfile
      end

      private

      attr_reader :gem_path

      def bundle_install!
        system("bundle", "install", chdir: ROOT, exception: true)
      rescue => error
        raise Error, "bundle install against the packaged gem failed: #{error.message}"
      end

      def point_gemfile_at(dir)
        contents = File.read(GEMFILE_PATH)
        updated = contents.sub(GEMSPEC_LINE, "gemspec path: #{dir.inspect}")

        if updated == contents
          raise Error, "Could not find a bare `gemspec` line to replace in #{GEMFILE_PATH}"
        end

        File.write(GEMFILE_PATH, updated)
      end

      def run_dummy_test_suite!
        system("bundle", "exec", "rake", "app:test", chdir: ROOT, exception: true)
      rescue => error
        raise Error, "The dummy app's test suite failed against the packaged gem: #{error.message}"
      end
    end
  end
end
