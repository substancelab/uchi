# frozen_string_literal: true

module Uchi
  class Field
    class HasAndBelongsToMany < Field
      DEFAULT_COLLECTION_QUERY = ->(query) { query }.freeze

      class Edit < Uchi::Field::Base::Edit
        def collection
          field.collection(record: record)
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

      attr_reader :collection_query

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

      def initialize(name, collection_query: DEFAULT_COLLECTION_QUERY, **args)
        super(name, **args)
        @collection_query = collection_query
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
