# frozen_string_literal: true

module Uchi::Flowbite
  class InputField
    class Url < InputField
      protected

      def input_component
        Uchi::Flowbite::Input::Url
      end
    end
  end
end
