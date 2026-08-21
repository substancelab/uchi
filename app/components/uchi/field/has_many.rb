# frozen_string_literal: true

module Uchi
  class Field
    class HasMany < Field
      DEFAULT_COLLECTION_QUERY = ->(query) { query }.freeze

      class Edit < Uchi::Field::Base::Edit
        def associated_records
          records = field.value(record)
          return [] if records.nil?

          return Array(records) if field.nested_fields.any?

          # For a new, unsaved record, loading the association (e.g. via
          # #to_a, to apply sorting/includes) would query using a nil foreign
          # key, which can match unrelated rows with a NULL value there
          # instead of just returning none. Use the association's in-memory
          # target instead
          return record.association(field.name).target if record.new_record?

          associated_repository.find_all(scope: records)
        end

        def associated_repository
          @associated_repository ||= begin
            model = reflection.klass
            repository_class = Uchi::Repository.for_model(model)
            repository_class.new
          end
        end

        def attribute_name
          "#{field.name.to_s.singularize}_ids"
        end

        def dom_id_for_filter_query_input
          "#{form.object_name}_#{attribute_name}_has_many_filter_query"
        end

        def dom_id_for_toggle
          "#{form.object_name}_#{attribute_name}_has_many_toggle"
        end

        def field_name_for_input
          "#{form.object_name}[#{attribute_name}][]"
        end

        def record_title(record)
          return "" if record.nil?

          associated_repository.title(record)
        end

        def selected_titles
          associated_records.map { |record| record_title(record) }.join(", ")
        end

        private

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

          return Array(records) if field.nested_fields.any?

          associated_repository.find_all(scope: records)
        end

        def associated_repository
          raise NameError, "No association named #{field.name.inspect} found on #{record.class}" unless reflection

          associated_model = reflection.klass
          repository_class = Uchi::Repository.for_model(associated_model)
          unless repository_class
            raise \
              NameError,
              "No repository found for associated model #{associated_model}"
          end

          repository_class.new
        end

        # Returns the scope to pass when linking to create a new record for
        # this association (e.g. from Company#show, to Person#new), so that
        # the new record ends up associated with this record.
        #
        # @return [Hash]
        def attach_scope
          {
            field: field.name,
            id: record.id,
            model: record.model_name.to_s
          }
        end

        private

        # Returns the Fields to be displayed for each associated record.
        #
        # @return [Array<Uchi::Field>]
        def fields
          all_fields = associated_repository.fields_for_index
          return all_fields unless inverse_association

          # Remove the field that represents the inverse association to avoid
          # a column containing nothing but the scoped record.
          all_fields.reject { |field| field.name == inverse_association.name }
        end

        # Returns the inverse association reflection, if any, for this
        # association.
        #
        # @return [ActiveRecord::Reflection, nil]
        def inverse_association
          reflection&.inverse_of
        end

        # Returns the ActiveRecord::Reflection for this association.
        #
        # @return [ActiveRecord::Reflection, nil]
        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end
      end

      def initialize(name)
        super
        @collection_query = DEFAULT_COLLECTION_QUERY
        @nested_fields = []
      end

      # Sets or gets a custom query for filtering the collection of associated records.
      #
      # When called with an argument, sets the query and returns self for chaining.
      # When called without arguments, returns the current query.
      #
      # @param query_proc [Proc, Symbol] A callable that receives an ActiveRecord query
      #   and returns a modified query.
      # @return [self, Proc] Returns self for method chaining when setting,
      #   or the query proc when getting
      #
      # @example Setting
      #   Field::HasMany.new(:users).collection_query(->(query) {
      #     query.where(active: true)
      #   })
      #
      # @example Getting
      #   field.collection_query # => #<Proc...>
      def collection_query(query_proc = Configuration::Unset)
        return @collection_query if query_proc == Configuration::Unset

        @collection_query = query_proc
        self
      end

      def group_as(_action)
        :associations
      end

      # Sets or gets the fields to display inline for each associated record.
      #
      # Configuring nested_fields switches this field from a select-and-link
      # UI (for choosing existing records) to an inline editor that creates,
      # edits, and deletes associated records directly within the parent form,
      # using Rails' nested attributes pattern. The model must declare
      # `accepts_nested_attributes_for` for this association.
      #
      # When called with an argument, sets the fields and returns self for
      # chaining. When called without arguments, returns the current fields.
      #
      # @param field_definitions [Array<Uchi::Field>] Field instances
      # @return [self, Array] Returns self for method chaining when setting,
      #   or the nested_fields array when getting
      #
      # @example Setting with field instances
      #   Field::HasMany.new(:titles).nested_fields(
      #     Field::String.new(:title),
      #     Field::String.new(:locale)
      #   )
      #
      # @example Setting with array
      #   Field::HasMany.new(:titles).nested_fields([
      #     Field::String.new(:title),
      #     Field::String.new(:locale)
      #   ])
      #
      # @example Getting
      #   field.nested_fields # => [#<Uchi::Field::String>, #<Uchi::Field::String>]
      def nested_fields(*field_definitions)
        return @nested_fields if field_definitions.empty?

        @nested_fields = field_definitions.flatten
        validate_nested_fields!
        self
      end

      def param_key
        return :"#{name}_attributes" if nested_fields.any?

        # TODO: This is too naive. We need to match this to the actual foreign
        # key of the model.
        :"#{name.to_s.singularize}_ids"
      end

      def permitted_param
        return {param_key => nested_permitted_params} if nested_fields.any?

        {param_key => []}
      end

      protected

      def default_sortable
        lambda { |query, direction|
          reflection = query.klass.reflect_on_association(name)
          return query unless reflection

          associated_table = reflection.klass.table_name
          associated_primary_key = reflection.klass.primary_key
          count = Arel.sql("COUNT(#{associated_table}.#{associated_primary_key})")
          primary_key = query.klass.arel_table[query.klass.primary_key]

          SortOrder.new(count, direction).apply(
            query
              .left_outer_joins(name)
              .group(primary_key)
          ).order(primary_key.asc)
        }
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
              "Field::HasMany#nested_fields expects Uchi::Field instances, " \
              "got #{field.class} (#{field.inspect}). " \
              "Example: Field::HasMany.new(:titles).nested_fields(Field::String.new(:title))"
          end
        end
      end
    end
  end
end
