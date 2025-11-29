# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class Email < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::Email
      end
    end
  end
end
