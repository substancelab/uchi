# frozen_string_literal: true

module Uchi::Flowbite
  class Input
    class DateTime < Input
      def input_field_type
        :datetime_field
      end
    end
  end
end
