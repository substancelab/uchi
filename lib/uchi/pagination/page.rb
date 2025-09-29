# frozen_string_literal: true

module Uchi
  module Pagination
    class Page
      delegate \
        :last,
        :next,
        :page,
        :page_url,
        to: :pagy

      private attr_reader :pagy

      def initialize(pagy)
        @pagy = pagy
      end
    end
  end
end
