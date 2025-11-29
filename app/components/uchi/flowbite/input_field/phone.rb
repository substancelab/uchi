# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class Phone < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::Phone
      end
    end
  end
end
