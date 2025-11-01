# frozen_string_literal: true

module Uchi
  class Field
    class Text < Field
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
      end

      class Show < Uchi::Field::Base::Show
      end

      protected

      def default_searchable?
        true
      end
    end
  end
end
