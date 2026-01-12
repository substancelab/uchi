# frozen_string_literal: true

module Uchi
  class Field
    class NestedMany < Field
      class Edit < Uchi::Field::Base::Edit
        def associated_records
          records = field.value(record)
          return [] if records.nil?

          Array(records)
        end

        def associated_repository
          @associated_repository ||= begin
            model = reflection.klass
            repository_class = Uchi::Repository.for_model(model)
            repository_class&.new
          end
        end

        def attribute_name
          field.param_key
        end

        def nested_field_components
          field.nested_fields
        end

        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end
      end

      class Index < Uchi::Field::Base::Index
      end

      class Show < Uchi::Field::Base::Show
        def associated_records
          records = field.value(record)
          return [] if records.nil?

          Array(records)
        end

        def associated_repository
          @associated_repository ||= begin
            model = reflection.klass
            repository_class = Uchi::Repository.for_model(model)
            repository_class&.new
          end
        end

        def nested_field_components
          field.nested_fields
        end

        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end
      end

      attr_reader :nested_fields

      def initialize(name)
        super
        @nested_fields = []
      end

      # Configures which fields to display inline for the nested records.
      #
      # @param field_definitions [Array<Uchi::Field>] Field instances
      # @return [self, Array] Returns self for method chaining when setting,
      #   or the nested_fields array when getting
      #
      # @example Setting with field instances
      #   Field::NestedMany.new(:titles).fields(
      #     Field::String.new(:title),
      #     Field::String.new(:locale)
      #   )
      #
      # @example Setting with array
      #   Field::NestedMany.new(:titles).fields([
      #     Field::String.new(:title),
      #     Field::String.new(:locale)
      #   ])
      #
      # @example Getting
      #   field.fields # => [#<Uchi::Field::String>, #<Uchi::Field::String>]
      def fields(*field_definitions)
        return @nested_fields if field_definitions.empty?

        @nested_fields = field_definitions.flatten
        validate_nested_fields!
        self
      end

      def group_as(_action)
        :associations
      end

      def param_key
        :"#{name}_attributes"
      end

      def permitted_param
        {param_key => nested_permitted_params}
      end

      private

      def nested_permitted_params
        # Base params: :id for existing records, :_destroy for deletion
        base_params = [:id, :_destroy]

        # Add each configured nested field's permitted param
        field_params = @nested_fields.map(&:permitted_param)

        base_params + field_params
      end

      def validate_nested_fields!
        @nested_fields.each do |field|
          unless field.is_a?(Uchi::Field)
            raise ArgumentError,
              "Field::NestedMany#fields expects Uchi::Field instances, " \
              "got #{field.class} (#{field.inspect}). " \
              "Example: Field::NestedMany.new(:titles).fields(Field::String.new(:title))"
          end
        end
      end
    end
  end
end
