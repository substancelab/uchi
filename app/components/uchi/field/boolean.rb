# frozen_string_literal: true

module Uchi
  class Field
    class Boolean < Field
      class Edit < Uchi::Field::Base::Edit
        private

        def options
          options = {
            form: form,
            attribute: field.name,
            label: {content: label}
          }
          options[:hint] = {content: hint} if hint.present?
          options
        end
      end

      class Index < Uchi::Field::Base::Index
      end

      class Show < Uchi::Field::Base::Show
      end
    end
  end
end
