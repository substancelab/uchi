# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require_relative "../rakelib/publish"

module Uchi
  module Publish
    class ChangelogTest < ActiveSupport::TestCase
      def changelog(contents)
        path = File.join(Dir.mktmpdir, "CHANGELOG.md")
        File.write(path, contents)
        Changelog.new(path: path)
      end

      test "entry_for returns the section matching the version" do
        subject = changelog(<<~MARKDOWN)
          # Changelog

          ## Unreleased

          - Something upcoming

          ## 0.2.1

          ### Added

          - A shiny new field

          ## 0.2.0

          - Older news
        MARKDOWN

        assert_equal "### Added\n\n- A shiny new field", subject.entry_for(version: "0.2.1")
        refute subject.unreleased?(version: "0.2.1")
      end

      test "entry_for falls back to the Unreleased section" do
        subject = changelog(<<~MARKDOWN)
          # Changelog

          ## Unreleased

          - Something upcoming

          ## 0.2.0

          - Older news
        MARKDOWN

        assert_equal "- Something upcoming", subject.entry_for(version: "0.2.1")
        assert subject.unreleased?(version: "0.2.1")
      end

      test "entry_for ignores empty sections" do
        subject = changelog(<<~MARKDOWN)
          ## Unreleased

          ## 0.2.0

          - Older news
        MARKDOWN

        assert_nil subject.entry_for(version: "0.2.1")
        refute subject.unreleased?(version: "0.2.1")
      end

      test "entry_for finds a bracketed heading" do
        subject = changelog(<<~MARKDOWN)
          ## [0.1.7]

          - Bracketed news
        MARKDOWN

        assert_equal "- Bracketed news", subject.entry_for(version: "0.1.7")
        refute subject.unreleased?(version: "0.1.7")
      end

      test "entry_for finds a bracketed heading with a release date" do
        subject = changelog(<<~MARKDOWN)
          ## [0.1.7] - 2026-01-05

          - Dated news
        MARKDOWN

        assert_equal "- Dated news", subject.entry_for(version: "0.1.7")
      end

      test "entry_for finds an unbracketed heading with a release date" do
        subject = changelog(<<~MARKDOWN)
          ## 0.1.7 - 2026-01-05

          - Dated news
        MARKDOWN

        assert_equal "- Dated news", subject.entry_for(version: "0.1.7")
      end

      test "entry_for finds a linked heading" do
        subject = changelog(<<~MARKDOWN)
          ## [0.1.7](https://github.com/substancelab/uchi/releases/tag/v0.1.7) - 2026-01-05

          - Linked news
        MARKDOWN

        assert_equal "- Linked news", subject.entry_for(version: "0.1.7")
      end

      test "entry_for prefers a bracketed version heading over the Unreleased section" do
        subject = changelog(<<~MARKDOWN)
          ## Unreleased

          - Something upcoming

          ## [0.1.7] - 2026-01-05

          - The notes we actually want
        MARKDOWN

        assert_equal "- The notes we actually want", subject.entry_for(version: "0.1.7")
        refute subject.unreleased?(version: "0.1.7")
      end

      test "entry_for falls back to a bracketed Unreleased heading" do
        subject = changelog(<<~MARKDOWN)
          ## [Unreleased]

          - Something upcoming
        MARKDOWN

        assert_equal "- Something upcoming", subject.entry_for(version: "0.2.1")
        assert subject.unreleased?(version: "0.2.1")
      end

      test "entry_for keeps a prerelease version intact" do
        subject = changelog(<<~MARKDOWN)
          ## [1.0.0-rc.1] - 2026-01-05

          - Release candidate news
        MARKDOWN

        assert_equal "- Release candidate news", subject.entry_for(version: "1.0.0-rc.1")
      end

      test "entry_for prefers the first of two headings naming the same version" do
        subject = changelog(<<~MARKDOWN)
          ## [0.1.7] - 2026-01-05

          - The newest notes

          ## 0.1.7

          - Stale duplicate
        MARKDOWN

        assert_equal "- The newest notes", subject.entry_for(version: "0.1.7")
      end

      test "entry_for returns nil when the changelog does not exist" do
        subject = Changelog.new(path: File.join(Dir.mktmpdir, "nope.md"))

        assert_nil subject.entry_for(version: "0.2.1")
      end
    end

    class TokenTest < ActiveSupport::TestCase
      test "token falls back to the gem credentials for the host" do
        with_environment("UCHI_GEM_PUSH_TOKEN" => nil, "GEM_HOST_API_KEY" => nil) do
          api_keys = {"https://gems.uchiadmin.com": "from-credentials"}

          assert_equal "from-credentials", Publish.token(api_keys: api_keys)
        end
      end

      test "token prefers UCHI_GEM_PUSH_TOKEN" do
        with_environment("UCHI_GEM_PUSH_TOKEN" => "uchi", "GEM_HOST_API_KEY" => "generic") do
          assert_equal "uchi", Publish.token
        end
      end

      test "token falls back to GEM_HOST_API_KEY" do
        with_environment("UCHI_GEM_PUSH_TOKEN" => nil, "GEM_HOST_API_KEY" => "generic") do
          assert_equal "generic", Publish.token(api_keys: {})
        end
      end

      test "token raises when no token is configured" do
        with_environment("UCHI_GEM_PUSH_TOKEN" => nil, "GEM_HOST_API_KEY" => nil) do
          assert_raises(Error) { Publish.token(api_keys: {}) }
        end
      end

      private

      def with_environment(values)
        original = values.keys.to_h { |key| [key, ENV[key]] }
        values.each { |key, value| ENV[key] = value }
        yield
      ensure
        original.each { |key, value| ENV[key] = value }
      end
    end
  end
end
