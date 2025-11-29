# frozen_string_literal: true

module Uchi::Flowbite
  module Input
    class DateTime < Field
      def input_field_type
        :datetime_field
      end
    end
  end
end
