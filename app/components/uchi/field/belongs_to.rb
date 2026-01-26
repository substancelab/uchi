# frozen_string_literal: true

module Uchi
  class Field
    class BelongsTo < Field
      DEFAULT_COLLECTION_QUERY = ->(query) { query }.freeze

      module Helpers
        def associated_record
          field.value(record)
        end

        def associated_repository
          reflection = record.class.reflect_on_association(field.name)

          unless reflection
            raise \
              ArgumentError,
              "No association named #{field.name.inspect} found on #{record.class}"
          end

          model = if reflection.polymorphic?
            associated_record&.class
          else
            reflection.klass
          end

          return nil if model.nil?

          repository_class = Uchi::Repository.for_model(model)
          repository_class.new
        end

        def label_for_associated_record
          associated_repository.title(associated_record)
        end
      end

      class Edit < Uchi::Field::Base::Edit
        include Helpers

        def associated_repository
          @associated_repository ||= begin
            model = if reflection.polymorphic?
              associated_record&.class
            else
              reflection.klass
            end

            return nil if model.nil?

            repository_class = Uchi::Repository.for_model(model)
            repository_class.new
          end
        end

        def attribute_name
          reflection.foreign_key
        end

        def dom_id_for_filter_query_input
          "#{form.object_name}_#{attribute_name}_belongs_to_filter_query"
        end

        def dom_id_for_toggle
          "#{form.object_name}_#{attribute_name}_belongs_to_toggle"
        end

        def record_title(record)
          return "" if record.nil?

          associated_repository.title(record)
        end

        private

        # Returns true if the association is optional.
        def optional?
          reflection.options[:optional] == true
        end

        def reflection
          @reflection ||= record.class.reflect_on_association(field.name)
        end
      end

      class Index < Uchi::Field::Base::Index
        include Helpers

        def render?
          associated_record.present?
        end
      end

      class Show < Uchi::Field::Base::Show
        include Helpers

        def path_to_show_associated_record
          associated_repository
            .routes
            .path_for(:show, id: associated_record.id)
        end

        def render?
          associated_record.present?
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

      # Returns the actions this field should appear on.
      #
      # For polymorphic associations, excludes :edit and :new to prevent showing
      # the field on forms where the type cannot be determined.
      def on(*actions)
        on = super
        return on - [:edit, :new] if polymorphic? && actions.empty?

        on
      end

      def param_key
        # TODO: This is too naive. We need to match this to the actual foreign
        # key of the model.
        :"#{name}_id"
      end

      private

      def polymorphic?
        return false unless repository

        reflection = repository.model.reflect_on_association(name)
        reflection&.polymorphic? || false
      end
    end
  end
end
