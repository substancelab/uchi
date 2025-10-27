# frozen_string_literal: true

module Uchi
  class Field
    class Base < Field
      # Uchi::Field::Base::Edit components render fields in the edit view.
      class Edit < ViewComponent::Base
        attr_reader :field, :form, :record, :repository, :label, :hint

        def initialize(field:, form:, repository:, label: nil, hint: nil)
          super()

          @field = field
          @form = form
          @label = label
          @hint = hint
          @record = form.object
          @repository = repository
        end
      end

      # Uchi::Field::Base::Show components render fields in the show view.
      class Show < ViewComponent::Base
        attr_reader :field, :record, :repository

        def initialize(field:, record:, repository:)
          super()

          @field = field
          @record = record
          @repository = repository
        end
      end

      # Uchi::Field::Base::Index components render fields in the index view.
      class Index < ViewComponent::Base
        attr_reader :field, :record, :repository

        class << self
          # Returns the CSS classes to apply to the td or th of the table where
          # this field is rendered.
          def classes_for_table_cell
            []
          end
        end

        def initialize(field:, record:, repository:)
          super()

          @field = field
          @record = record
          @repository = repository
        end
      end
    end
  end
end
