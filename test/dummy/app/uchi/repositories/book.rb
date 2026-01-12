module Uchi
  module Repositories
    class Book < Repository
      def fields
        [
          Field::HasMany.new(:titles),
          Field::String.new(:original_title),
          Field::NestedMany.new(:titles).fields(
            Field::String.new(:title),
            Field::String.new(:locale)
          ).on(:edit, :show)
        ]
      end

      def title(model)
        model.original_title
      end
    end
  end
end
