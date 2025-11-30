# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class Number < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::Number
      end
    end
  end
end
