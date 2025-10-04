# frozen_string_literal: true

module Uchi
  class Field
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
