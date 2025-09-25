# frozen_string_literal: true

module Uchi
  module Ui
    class Pagination
      class Item < ViewComponent::Base
        attr_reader :page_number, :paginator

        # @param paginator [Pagy::Pagy] The Pagy object
        def initialize(paginator:, page_number: nil)
          super()
          @page_number = page_number
          @paginator = paginator
        end

        # Returns the URL for a given page. page can be a number, of :first,
        # :last, :previous, :next, :current.
        def page_url(page)
          paginator.page_url(page)
        end
      end
    end
  end
end
