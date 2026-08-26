# frozen_string_literal: true

require "net/http"
require "rubygems"
require "uri"

module Uchi
  # Development-only support code for releasing the Uchi gem to the Uchi
  # Mothership (https://www.uchiadmin.com) instead of rubygems.org.
  #
  # This file lives outside lib/ on purpose: it is not part of the released
  # gem.
  module Publish
    # The gem server we push releases to.
    HOST = "https://gems.uchiadmin.com"
    # HOST = "http://gems.uchiadmin.test" # For local development

    # Environment variables we look for an API token in, in order of
    # precedence.
    TOKEN_VARIABLES = ["UCHI_GEM_PUSH_TOKEN", "GEM_HOST_API_KEY"].freeze

    Error = Class.new(StandardError)

    # Extracts the release notes for a single version from a Keep a Changelog
    # formatted CHANGELOG.md.
    class Changelog
      # Headings we accept as "the notes for the version being released" when
      # no heading matches the version itself.
      UNRELEASED_HEADINGS = ["Unreleased", "Unversioned", "Next"].freeze

      # Matches a Markdown link, so "[0.1.7](https://...)" reduces to "0.1.7".
      LINKED_HEADING = /\A\[([^\]]*)\]\([^)]*\)/
      # Matches the trailing release date in "0.1.7 - 2026-01-05". The
      # surrounding whitespace is required so prereleases like "1.0.0-rc.1"
      # survive intact.
      TRAILING_DATE = /\s+[-\u2013\u2014]\s+.*\z/

      def initialize(path:)
        @path = path
      end

      # Returns the release notes for the given version, or nil if we cannot
      # find any.
      #
      # Prefers a heading matching the version exactly, falling back to an
      # "Unreleased" heading for the common case where the changelog has not
      # been renamed before releasing.
      def entry_for(version:)
        section_for(heading: version) || unreleased_section
      end

      # True if the notes we found came from an "Unreleased" style heading
      # rather than from a heading naming the version.
      def unreleased?(version:)
        section_for(heading: version).nil? && !unreleased_section.nil?
      end

      private

      attr_reader :path

      def contents
        @contents ||= File.exist?(path) ? File.read(path) : ""
      end

      # Reduces a heading to the version or label it names, so that
      # "[0.1.7] - 2026-01-05", "[0.1.7](https://...)", "[0.1.7]" and "0.1.7"
      # all look up as "0.1.7".
      #
      # Keep a Changelog brackets the version and appends the release date, but
      # both are optional in the wild and our own changelog mixes the styles.
      def key_for(heading)
        heading
          .sub(LINKED_HEADING, '\1')
          .delete("[]")
          .sub(TRAILING_DATE, "")
          .strip
          .downcase
      end

      # Splits the changelog into a Hash of version => body, for every level 2
      # heading in the document. Where two headings name the same version the
      # first one wins, since Keep a Changelog lists the newest first.
      def sections
        @sections ||= contents
          .split(/^## +/)
          .drop(1)
          .each_with_object({}) { |section, result|
            heading, _newline, body = section.partition("\n")
            result[key_for(heading)] ||= body.strip
          }
      end

      def section_for(heading:)
        body = sections[key_for(heading)]
        return nil if body.nil? || body.empty?

        body
      end

      def unreleased_section
        UNRELEASED_HEADINGS.filter_map { |heading| section_for(heading: heading) }.first
      end
    end

    # Uploads a built .gem file, and its release notes, to the Uchi
    # Mothership.
    class Publisher
      def initialize(changelog:, host:, path:, token:, version:)
        @changelog = changelog
        @host = host
        @path = path
        @token = token
        @version = version
      end

      # Pushes the gem, raising Error if the Mothership rejects it.
      def publish!
        response = post

        case response
        when Net::HTTPSuccess
          response.body.to_s.strip
        when Net::HTTPUnauthorized, Net::HTTPForbidden
          raise Error, "#{host} rejected the API token. Check UCHI_GEM_PUSH_TOKEN, or generate a new token in the backend."
        else
          raise Error, "#{host} returned #{response.code} #{response.message}: #{response.body}"
        end
      end

      private

      attr_reader :changelog, :host, :path, :token, :version

      def endpoint
        URI.join(host, "/api/v1/gems")
      end

      def form_data(file:)
        [
          ["changelog", changelog.to_s],
          ["gem", file, {filename: File.basename(path), content_type: "application/octet-stream"}],
          ["version", version]
        ]
      end

      def post
        request = Net::HTTP::Post.new(endpoint)
        request["Accept"] = "text/plain"
        request["Authorization"] = token
        request["User-Agent"] = "uchi-release/#{version}"

        File.open(path, "rb") do |file|
          request.set_form(form_data(file: file), "multipart/form-data")

          Net::HTTP.start(endpoint.host, endpoint.port, use_ssl: endpoint.scheme == "https") do |http|
            http.request(request)
          end
        end
      end
    end

    # Returns the API token to authenticate against the Mothership with,
    # raising Error when we cannot find one.
    def self.token(api_keys: Gem.configuration.api_keys, host: HOST)
      token = TOKEN_VARIABLES.filter_map { |name| presence(ENV[name]) }.first
      token ||= presence(api_keys[host.to_sym].to_s) if api_keys.key?(host.to_sym)

      token || raise(Error, <<~MESSAGE)
        No API token found for #{host}.

        Generate a token under Account in the Uchi backend and either

          export UCHI_GEM_PUSH_TOKEN=<your token>

        or store it in ~/.gem/credentials with

          gem signin --host #{host}
      MESSAGE
    end

    def self.presence(value)
      return nil if value.nil?

      stripped = value.strip
      stripped.empty? ? nil : stripped
    end
    private_class_method :presence
  end
end
