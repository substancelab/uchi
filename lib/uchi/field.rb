# frozen_string_literal: true

module Uchi
  class Field
    DEFAULT_READER = ->(record, field_name) { record.public_send(field_name) }

    attr_reader \
      :on,
      :name,
      :reader,
      :sortable

    # The repository this field is associated with.
    attr_accessor :repository

    def column_name
      name.to_s.humanize
    end

    def group_as(_action)
      :attributes
    end

    def edit_component(form:, repository:, label: nil, hint: nil)
      edit_component_class.new(
        field: self,
        form: form,
        repository: repository,
        label: label,
        hint: hint
      )
    end

    def edit_component_class
      self.class.const_get(:Edit)
    end

    def index_component(record:, repository:)
      index_component_class.new(
        field: self,
        record: record,
        repository: repository
      )
    end

    def index_component_class
      self.class.const_get(:Index)
    end

    # @param name [String, Symbol] The name of the field.
    #
    # @param reader [Proc] A callable that reads the value from a record. reader
    # can be customized with a lambda that received the model in question and
    # the name of the field we're reading. The lambda should return the value of
    # the field for the given record.
    #
    # @param searchable [Boolean] Whether the field is searchable in index
    #   views. Pass it a simple boolean (false or true). Defaults to false for
    #   most fields, except Uchi::Field::String and Uchi::Field::Text.
    #
    # @param sortable [Boolean] Whether the field is sortable in index views.
    #   Pass it a simple boolean (false or true), or it can be configured with a
    #   lambda, which receives the query and direction and must return an
    #   ActiveRecord::Relation. Defaults to true.
    def initialize(name, on: default_on, reader: DEFAULT_READER, searchable: default_searchable?, sortable: true)
      @on = on
      @reader = reader
      @name = name.to_sym
      @searchable = searchable
      @sortable = sortable
    end

    # Returns the key that this field is expected to use in params
    def param_key
      name.to_sym
    end

    # Returns the values to use for permitting this field in strong parameters
    def permitted_param
      param_key
    end

    # Returns true if the field is searchable and should be included in the
    # query when a search term has been entered.
    def searchable?
      return !!@searchable unless @searchable.nil?

      default_searchable?
    end

    def show_component(record:, repository:)
      show_component_class.new(
        field: self,
        record: record,
        repository: repository
      )
    end

    def show_component_class
      self.class.const_get(:Show)
    end

    # Returns true if the field is sortable
    def sortable?
      !!sortable
    end

    def value(record)
      reader.call(record, name)
    end

    protected

    def default_on
      [:edit, :index, :show]
    end

    def default_searchable?
      false
    end
  end
end
