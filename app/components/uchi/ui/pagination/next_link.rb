# frozen_string_literal: true

module Uchi
  module Ui
    class Pagination
      class NextLink < Item
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
