module Uchi
  module Repositories
    class Book < Repository
      def fields
        [
          Field::HasMany.new(:titles).nested_fields(
            Field::String.new(:title),
            Field::String.new(:locale)
          ),
          Field::String.new(:original_title)
        ]
      end

      def title(model)
        model.original_title
      end
    end
  end
end
