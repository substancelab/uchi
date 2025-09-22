# frozen_string_literal: true

module Uchi
  class Field
    DEFAULT_READER = ->(record, field_name) { record.public_send(field_name) }

    attr_reader \
      :on,
      :name,
      :reader,
      :sortable

    def column_name
      name.to_s.humanize
    end

    def group_as(_action)
      :attributes
    end

    def edit_component(form:, repository:, label: nil, hint: nil)
      component_class = self.class.const_get(:Edit)
      component_class.new(
        :field => self,
        :form => form,
        :repository => repository,
        :label => label,
        :hint => hint
      )
    end

    def index_component(record:, repository:)
      component_class = self.class.const_get(:Index)
      component_class.new(
        :field => self,
        :record => record,
        :repository => repository
      )
    end

    # @param name [String, Symbol] The name of the field.
    #
    # @param reader [Proc] A callable that reads the value from a record. reader
    # can be customized with a lambda that received the model in question and
    # the name of the field we're reading. The lambda should return the value of
    # the field for the given record.
    #
    # @param sortable [Boolean] Whether the field is sortable in index views.
    # Pass it a simple boolean (false or true), or it can be configured with a
    # lambda, which receives the query and direction and must return an
    # ActiveRecord::Relation. Defaults to true.
    def initialize(name, on: [:edit, :index, :show], reader: DEFAULT_READER, sortable: true)
      @on = on
      @reader = reader
      @name = name.to_sym
      @sortable = sortable
    end

    # Returns the key that this field is expected to use in params
    def param_key
      name.to_sym
    end

    # Returns true if the field is a primary key
    def primary_key?
      # TODO: This should probably be configurable
      name == :id
    end

    def show_component(record:, repository:)
      component_class = self.class.const_get(:Show)
      component_class.new(
        :field => self,
        :record => record,
        :repository => repository
      )
    end

    # Returns true if the field is sortable
    def sortable?
      !!sortable
    end

    def value(record)
      reader.call(record, name)
    end
  end
end
