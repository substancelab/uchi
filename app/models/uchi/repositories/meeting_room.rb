# frozen_string_literal: true

module Uchi
  module Repositories
    class MeetingRoom < Repository
      def default_sort_order
        SortOrder.new(:name, :asc)
      end

      def fields
        [
          Field::BelongsTo.new(
            :office,
            :collection_query => ->(query) { query.reorder(:name) },
            :sortable => false
          ),
          Field::Number.new(:id, :on => [:show]),
          Field::Text.new(:name),
          Field::Number.new(:max_people),
          Field::Boolean.new(:visible),
          Field::HasMany.new(
            :reservations,
            :collection_query => ->(query) { query.reorder(:starts_at => :desc) },
            :on => [:show],
            :sortable => false
          ),
        ]
      end

      def includes
        [:office]
      end
    end
  end
end
