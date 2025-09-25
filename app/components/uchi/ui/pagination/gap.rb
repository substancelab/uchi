# frozen_string_literal: true

module Uchi
  module Ui
    class Pagination
      class Gap < ViewComponent::Base
        attr_reader :page_number, :paginator

        # @param paginator [Pagy::Pagy] The Pagy object
        def initialize(paginator:, page_number: nil)
          super()
          @page_number = page_number
          @paginator = paginator
        end
      end
    end
  end
end
