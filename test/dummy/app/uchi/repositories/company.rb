module Uchi
  module Repositories
    class Company < Repository
      def fields
        [
          Field::HasMany.new(:people),
          Field::String.new(:name)
        ]
      end
    end
  end
end
