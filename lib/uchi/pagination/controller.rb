# frozen_string_literal: true

require "uchi/pagy"

require "uchi/pagination/page"

module Uchi
  module Pagination
    module Controller
      include Pagy::Method

      # Set up pagination for the given records. Returns a Page object and the
      # paginated records for that page.
      #
      # @param records [ActiveRecord::Relation] The records to paginate
      #
      # @param records_per_page [Integer] The number of records per page
      #
      # @return [Array<(Uchi::Pagination::Page, ActiveRecord::Relation)>]
      def paginate(records, records_per_page:)
        page, records = pagy(:offset, records, limit: records_per_page)
        [Uchi::Pagination::Page.new(page), records]
      end
    end
  end
end
