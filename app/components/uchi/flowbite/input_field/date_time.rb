# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class DateTime < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::DateTime
      end
    end
  end
end
