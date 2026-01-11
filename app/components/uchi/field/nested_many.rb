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
          @nested_field_components ||= build_nested_field_components
        end

        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end

        private

        def build_nested_field_components
          field.nested_fields.map do |field_def|
            case field_def
            when Symbol
              infer_field_type(field_def)
            when Hash
              field_name = field_def.keys.first
              field_options = field_def.values.first
              build_custom_field(field_name, field_options)
            end
          end.compact
        end

        def build_custom_field(field_name, options)
          field_type = options[:type] || :string
          field_class = "Uchi::Field::#{field_type.to_s.camelize}".constantize
          field_class.new(field_name).tap do |field|
            field.on(*options[:on]) if options[:on]
            field.searchable(options[:searchable]) if options.key?(:searchable)
          end
        end

        def infer_field_type(field_name)
          # Try to get field from associated repository first
          if associated_repository&.respond_to?(:fields)
            repo_field = associated_repository.fields.find { |f| f.name == field_name }
            return repo_field if repo_field
          end

          # Fall back to column type inference
          column = reflection.klass.columns_hash[field_name.to_s]
          return nil unless column

          case column.type
          when :string then Field::String.new(field_name)
          when :text then Field::Text.new(field_name)
          when :integer, :decimal, :float then Field::Number.new(field_name)
          when :boolean then Field::Boolean.new(field_name)
          when :date then Field::Date.new(field_name)
          when :datetime, :timestamp then Field::DateTime.new(field_name)
          else
            Rails.logger.warn(
              "Field::NestedMany: Could not infer field type for #{field_name} " \
              "on #{reflection.klass.name}, using String"
            )
            Field::String.new(field_name)
          end
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
          @nested_field_components ||= build_nested_field_components
        end

        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end

        private

        def build_nested_field_components
          field.nested_fields.map do |field_def|
            case field_def
            when Symbol
              infer_field_type(field_def)
            when Hash
              field_name = field_def.keys.first
              field_options = field_def.values.first
              build_custom_field(field_name, field_options)
            end
          end.compact
        end

        def build_custom_field(field_name, options)
          field_type = options[:type] || :string
          field_class = "Uchi::Field::#{field_type.to_s.camelize}".constantize
          field_class.new(field_name).tap do |field|
            field.on(*options[:on]) if options[:on]
            field.searchable(options[:searchable]) if options.key?(:searchable)
          end
        end

        def infer_field_type(field_name)
          # Try to get field from associated repository first
          if associated_repository&.respond_to?(:fields)
            repo_field = associated_repository.fields.find { |f| f.name == field_name }
            return repo_field if repo_field
          end

          # Fall back to column type inference
          column = reflection.klass.columns_hash[field_name.to_s]
          return nil unless column

          case column.type
          when :string then Field::String.new(field_name)
          when :text then Field::Text.new(field_name)
          when :integer, :decimal, :float then Field::Number.new(field_name)
          when :boolean then Field::Boolean.new(field_name)
          when :date then Field::Date.new(field_name)
          when :datetime, :timestamp then Field::DateTime.new(field_name)
          else
            Rails.logger.warn(
              "Field::NestedMany: Could not infer field type for #{field_name} " \
              "on #{reflection.klass.name}, using String"
            )
            Field::String.new(field_name)
          end
        end
      end

      attr_reader :nested_fields

      def initialize(name)
        super
        @nested_fields = []
      end

      # Configures which fields to display inline for the nested records.
      #
      # @param field_definitions [Array<Symbol, Hash>] Field names or configurations
      # @return [self, Array] Returns self for method chaining when setting,
      #   or the nested_fields array when getting
      #
      # @example Setting with symbols
      #   Field::NestedMany.new(:titles).fields(:title, :language, :published_on)
      #
      # @example Setting with array
      #   Field::NestedMany.new(:titles).fields([:title, :language])
      #
      # @example Getting
      #   field.fields # => [:title, :language]
      def fields(*field_definitions)
        return @nested_fields if field_definitions.empty?

        @nested_fields = field_definitions.flatten
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

        # Add each configured nested field
        field_params = @nested_fields.map do |field_def|
          if field_def.is_a?(Symbol)
            field_def
          elsif field_def.is_a?(Hash)
            field_def.keys.first
          end
        end

        base_params + field_params
      end
    end
  end
end
