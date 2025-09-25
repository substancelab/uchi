# frozen_string_literal: true

module Uchi
  module Ui
    class Pagination
      class PreviousLink < Item
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
