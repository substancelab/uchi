# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class Textarea < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::Textarea
      end
    end
  end
end
