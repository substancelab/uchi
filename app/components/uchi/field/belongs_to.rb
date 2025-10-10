# frozen_string_literal: true

module Uchi
  class Field
    class BelongsTo < Field
      DEFAULT_COLLECTION_QUERY = ->(query) { query }.freeze

      class Edit < Uchi::Field::Base::Edit
        def associated_repository
          model = reflection.klass
          repository_class = Uchi::Repository.for_model(model)
          repository_class.new
        end

        def attribute_name
          reflection.foreign_key
        end

        def collection
          query = associated_repository.find_all
          field.collection_query.call(query)
        end

        private

        def collection_for_select
          repository = associated_repository
          collection.map do |item|
            [repository.title(item), item.id]
          end
        end

        def options
          options = {
            attribute: attribute_name,
            collection: collection_for_select,
            form: form,
            label: {content: label}
          }
          options[:hint] = {content: hint} if hint.present?
          options
        end

        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end
      end

      class Index < Uchi::Field::Base::Index
      end

      class Show < Uchi::Field::Base::Show
        def associated_record
          field.value(record)
        end

        def associated_repository
          reflection = record.class.reflect_on_association(field.name)
          model = reflection.klass
          repository_class = Uchi::Repository.for_model(model)
          repository_class.new
        end
      end

      attr_reader :collection_query

      def initialize(name, collection_query: DEFAULT_COLLECTION_QUERY, **args)
        super(name, **args)
        @collection_query = collection_query
      end

      def group_as(_action)
        :attributes
      end

      def param_key
        # TODO: This is too naive. We need to match this to the actual foreign
        # key of the model.
        :"#{name}_id"
      end
    end
  end
end
