module Uchi
  module Repositories
    class Author < Repository
      def fields
        [
          Field::Number.new(:id, on: [:index, :show]),
          Field::String.new(:name),
          Field::Date.new(:born_on),
          Field::String.new(:biography, on: [:edit, :new, :show])
        ]
      end

      def title(model)
        model.name
      end
    end
  end
end
