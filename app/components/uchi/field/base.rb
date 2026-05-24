# frozen_string_literal: true

module Uchi
  class Field
    class Base < Field
      class Component < ViewComponent::Base
        attr_reader :field, :record, :repository

        def initialize(field:, record:, repository:)
          super()

          @field = field
          @record = record
          @repository = repository
        end

        # Returns the raw value of the field as returned by the field's value
        # method.
        def value
          return @value if instance_variable_defined?(:@value)

          @value = field.value(record)
        end
      end

      # Uchi::Field::Base::Edit components render fields in the edit view.
      class Edit < Component
        attr_reader :form, :label, :hint

        def initialize(field:, form:, repository:, label: nil, hint: nil)
          super(field:, record: form.object, repository:)
          @form = form
          @label = label
          @hint = hint
        end
      end

      # Uchi::Field::Base::Index components render fields in the index view.
      class Index < Component
        class << self
          # Returns the CSS classes to apply to the td or th of the table where
          # this field is rendered.
          def classes_for_table_cell
            []
          end
        end
      end

      # Uchi::Field::Base::Show components render fields in the show view.
      class Show < Component
      end
    end
  end
end
