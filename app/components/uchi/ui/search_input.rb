# frozen_string_literal: true

module Uchi
  module Ui
    # Renders a labelled search input with a submit button, for use inside a
    # `form_tag`. This is the shared building block behind both the global
    # search form and each repository's index page search form.
    #
    # Based on Flowbite's Simple search input
    # (https://flowbite.com/docs/forms/search-input/#simple-search-input)
    class SearchInput < ViewComponent::Base
      attr_reader :autofocus, :label, :query

      def initialize(autofocus: false, label: nil, query: nil)
        super()
        @autofocus = autofocus
        @label = label || Uchi::I18n.translate("search.label", default: "Search")
        @query = query
      end
    end
  end
end
