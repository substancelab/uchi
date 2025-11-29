# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class Password < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::Password
      end
    end
  end
end
