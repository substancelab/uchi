# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class File < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::File
      end
    end
  end
end
