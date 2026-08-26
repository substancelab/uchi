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

      # Splits the changelog into a Hash of heading => body, for every level 2
      # heading in the document.
      def sections
        @sections ||= contents
          .split(/^## +/)
          .drop(1)
          .to_h { |section|
            heading, _newline, body = section.partition("\n")
            [heading.strip, body.strip]
          }
      end

      def section_for(heading:)
        body = sections[heading]
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

      def form_data
        [
          ["changelog", changelog.to_s],
          ["gem", File.open(path, "rb"), {filename: File.basename(path), content_type: "application/octet-stream"}],
          ["version", version]
        ]
      end

      def post
        request = Net::HTTP::Post.new(endpoint)
        request["Accept"] = "text/plain"
        request["Authorization"] = token
        request["User-Agent"] = "uchi-release/#{version}"
        request.set_form(form_data, "multipart/form-data")

        Net::HTTP.start(endpoint.host, endpoint.port, use_ssl: endpoint.scheme == "https") do |http|
          http.request(request)
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
