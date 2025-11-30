# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class Date < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::Date
      end
    end
  end
end
