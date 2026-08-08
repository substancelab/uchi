# frozen_string_literal: true

module Uchi
  module Ui
    # Renders the global search form shown in the application layout.
    #
    # Based on Flowbite's Simple search input
    # (https://flowbite.com/docs/forms/search-input/#simple-search-input)
    class SearchForm < ViewComponent::Base
      attr_reader :query

      def initialize(query: nil)
        super()
        @query = query
      end

      def label
        Uchi::I18n.translate("search.label", default: "Search")
      end

      def path
        Uchi.routes.search_path
      end

      def render?
        Uchi::Repository.any_searchable?
      end
    end
  end
end
