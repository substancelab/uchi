# frozen_string_literal: true

module Uchi
  class Repository
    class Routes
      attr_reader :plural, :repository, :singular

      def initialize(repository)
        @repository = repository
        @singular = repository.controller_name.singularize
        @plural = repository.controller_name.pluralize
      end

      def path_for(action, **options)
        action = action.to_sym
        case action
        when :edit, :new, :show, :update
          singular_path_for(action, **options)
        else
          plural_path_for(action, **options)
        end
      end

      private

      def call_url_helper_in_main_app(parts, **options)
        url_helper_name = parts.join("_")
        Rails.application.routes.url_helpers.send(url_helper_name, **options)
      end

      def plural_path_for(_action, **options)
        parts = [
          uchi_namespace,
          plural,
          "path"
        ].compact
        call_url_helper_in_main_app(parts, **options)
      end

      def singular_path_for(action, **options)
        action = nil if action == :show
        action = nil if action == :update
        parts = [
          action,
          uchi_namespace,
          singular,
          "path"
        ].compact
        call_url_helper_in_main_app(parts, **options)
      end

      def uchi_namespace
        :uchi
      end
    end
  end
end
