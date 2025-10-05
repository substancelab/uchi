module Uchi
  module Repositories
    class Book < Repository
      def fields
        [
          Field::HasMany.new(:titles),
          Field::String.new(:original_title)
        ]
      end

      def title(model)
        model.original_title
      end
    end
  end
end
