# frozen_string_literal: true

module Uchi
  module Ui
    class Pagination
      class NextLink < ViewComponent::Base
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

        # Returns true if there is a next page
        def next?
          paginator.next.present?
        end

        def url
          if next?
            page_url(:next)
          else
            page_url(:last)
          end
        end
      end
    end
  end
end
