module Uchi
  module Repositories
    class Title < Repository
      def fields
        [
          Field::BelongsTo.new(:book),
          Field::String.new(:locale),
          Field::String.new(:title)
        ]
      end
    end
  end
end
