# frozen_string_literal: true

module Uchi
  class Field
    class File < Field
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
        false
      end

      def default_sortable?
        false
      end
    end
  end
end
