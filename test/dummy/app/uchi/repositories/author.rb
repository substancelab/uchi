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

      def max_number_of_actions_outside_dropdown
        1
      end
    end
  end
end
