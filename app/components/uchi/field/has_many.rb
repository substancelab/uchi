# frozen_string_literal: true

module Uchi
  class Field
    class HasMany < Field
      DEFAULT_COLLECTION_QUERY = ->(query) { query }.freeze

      class Edit < Uchi::Field::Base::Edit
        def associated_records
          records = field.value(record)
          return [] if records.nil?

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

          associated_repository.find_all(scope: records)
        end

        def associated_repository
          reflection = record.class.reflect_on_association(field.name)
          model = reflection.klass
          repository_class = Uchi::Repository.for_model(model)
          raise NameError, "No repository found for associated model #{model}" unless repository_class

          repository_class.new
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
          reflection = record.class.reflect_on_association(field.name)
          reflection&.inverse_of
        end

        # Returns the ActiveRecord::Reflection for this association.
        #
        # @return [ActiveRecord::Reflection]
        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end
      end

      def initialize(name)
        super
        @collection_query = DEFAULT_COLLECTION_QUERY
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

      def param_key
        # TODO: This is too naive. We need to match this to the actual foreign
        # key of the model.
        :"#{name.to_s.singularize}_ids"
      end

      def permitted_param
        {param_key => []}
      end
    end
  end
end
