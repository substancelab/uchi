# frozen_string_literal: true

module Uchi
  module Repositories
    class Office < Repository
      def default_sort_order
        SortOrder.new(:name, :asc)
      end

      # Returns an array of fields to show for this resource.
      def fields
        [
          Field::Number.new(:id, :on => [:show]),
          Field::Text.new(:name),
          Field::Text.new(:stripe_subscription_item_id),
          Field::Date.new(:paid_until),
          Field::Number.new(
            :users_count,
            :on => [:index],

            :reader => ->(record, _attribute_name) { record.users.count },

            :sortable => lambda { |query, direction|
              query.joins(:users).group(:id).order("COUNT(users.id) #{direction}")
            }
          ),

          Field::HasMany.new(:meeting_rooms, :sortable => false),
        ]
      end

      def title(record)
        record.name
      end
    end
  end
end
