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
          items = []
          items << ["", nil] if optional?
          items + collection.map do |item|
            [repository.title(item), item.id]
          end
        end

        # Returns true if the association is optional.
        def optional?
          reflection.options[:optional] == true
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
      #   Field::BelongsTo.new(:company).collection_query(->(query) {
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
