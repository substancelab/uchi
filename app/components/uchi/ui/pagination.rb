# frozen_string_literal: true

module Uchi
  module Ui
    class Pagination < ViewComponent::Base
      attr_reader :paginator

      def aria_label
        "Page navigation"
      end

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

      # Returns an array of page numbers to display in the pagination component
      def pages
        pages = []
        pages += [1]
        pages += (paginator.page - 2..paginator.page + 2).to_a
        pages += [paginator.last]
        pages = pages.select { |page| page >= 1 && page <= paginator.last }.uniq.sort

        result = []
        pages.each_with_index do |page, index|
          result << page
          next_page = pages[index + 1]
          if index < pages.size - 1 && next_page - page > 1
            result << nil # Add a gap
          end
        end
        result
      end

      def render?
        paginator.present?
      end
    end
  end
end
