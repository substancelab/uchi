# frozen_string_literal: true

module Uchi
  class Field
    # The Id field is intended for unique identifiers, such as primary keys. It
    # contains a link to the records show page, and is not considered editable.
    # As such it is only displayed in index and show views by default.
    class Id < Number
      class Index < Uchi::Field::Base::Index
      end

      class Show < Uchi::Field::Base::Show
      end

      protected

      def default_on
        [:index, :show]
      end

      def default_searchable?
        true
      end
    end
  end
end
