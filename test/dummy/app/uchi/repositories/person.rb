module Uchi
  module Repositories
    class Person < Repository
      def fields
        [
          Field::String.new(:name),
          Field::HasMany.new(:companies)
        ]
      end
    end
  end
end
