module Uchi
  module Repositories
    class Author < Repository
      def fields
        [
          Field::Number.new(:id).on(:index, :show),
          Field::String.new(:name),
          Field::Date.new(:born_on),
          Field::Text.new(:biography).on(:edit, :new, :show)
        ]
      end
    end
  end
end
