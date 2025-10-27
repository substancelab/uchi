# frozen_string_literal: true

module Uchi
  class Field
    class Number < Field
      class Edit < Uchi::Field::Base::Edit
        private

        def options
          options = {
            attribute: field.name,
            form: form,
            label: {content: label}
          }
          options[:hint] = {content: hint} if hint.present?
          options
        end
      end

      class Index < Uchi::Field::Base::Index
        class << self
          def classes_for_table_cell
            super + ["text-right"]
          end
        end
      end

      class Show < Uchi::Field::Base::Show
      end
    end
  end
end
