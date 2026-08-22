# frozen_string_literal: true

module Uchi
  module Ui
    class Navigation
      # Renders the icon link to the search page shown in the main
      # navigation.
      class SearchLink < ViewComponent::Base
        attr_reader :html_class

        def initialize(html_class: nil)
          super()
          @html_class = html_class
        end

        def path
          Uchi.routes.search_path
        end
      end
    end
  end
end
