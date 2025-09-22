# frozen_string_literal: true

module Uchi
  module Repositories
    class Reservation < Repository
      def fields
        [
          Field::BelongsTo.new(:meeting_room, sortable: false),
          Field::Text.new(:reason),
          Field::DateTime.new(:starts_at),
          Field::DateTime.new(:ends_at)
        ]
      end

      def includes
        [:meeting_room]
      end
    end
  end
end
