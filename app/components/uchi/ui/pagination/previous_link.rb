# frozen_string_literal: true

module Uchi
  module Ui
    class Pagination
      class PreviousLink < ViewComponent::Base
        attr_reader :paginator

        # @param paginator [Pagy::Pagy] The Pagy object
        def initialize(paginator:)
          super()
          @paginator = paginator
        end

        # Returns the URL for a given page. page can be a number, of :first,
        # :last, :previous, :next, :current.
        def page_url(page)
          paginator.page_url(page)
        end

        # Returns true if there is a previous page
        def previous?
          paginator.page > 1
        end

        def url
          if previous?
            page_url(:previous)
          else
            page_url(:first)
          end
        end
      end
    end
  end
end
