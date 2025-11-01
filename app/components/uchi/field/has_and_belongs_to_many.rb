# frozen_string_literal: true

module Uchi
  class Field
    class HasAndBelongsToMany < Field
      DEFAULT_COLLECTION_QUERY = ->(query) { query }.freeze

      class Edit < Uchi::Field::Base::Edit
        def collection
          associated_repository = field.associated_repository(record: record)

          field
            .collection(record: record)
            .map { |associated_record|
              [
                associated_repository.title(associated_record),
                associated_record.id
              ]
            }
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
          field.associated_repository(record: record)
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

      def associated_repository(record:)
        reflection = record.class.reflect_on_association(name)
        model = reflection.klass
        repository_class = Uchi::Repository.for_model(model)
        raise NameError, "No repository found for associated model #{model}" unless repository_class

        repository_class.new
      end

      def collection(record:)
        query = associated_repository(record: record).find_all
        @collection_query.call(query)
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
      #   Field::HasAndBelongsToMany.new(:tags).collection_query(->(query) {
      #     query.where(active: true)
      #   })
      #
      # @example Getting
      #   field.collection_query # => #<Proc...>
      def collection_query(query_proc = NoValue)
        return @collection_query if query_proc == NoValue

        @collection_query = query_proc
        self
      end

      def group_as(_action)
        :associations
      end

      # Returns the key to use for this field in params
      def param_key
        association.association_foreign_key.pluralize.to_sym
      end

      def permitted_param
        {param_key => []}
      end

      protected

      def association
        @association ||= repository.model.reflect_on_association(name)
      end
    end
  end
end
