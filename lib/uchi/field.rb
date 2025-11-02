# frozen_string_literal: true

require_relative "field/configuration"

module Uchi
  class Field
    include Configuration

    attr_reader :name

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
    def initialize(name)
      super()
      @name = name.to_sym
    end

    # Returns the key that this field is expected to use in params
    def param_key
      name.to_sym
    end

    # Returns the values to use for permitting this field in strong parameters
    def permitted_param
      param_key
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

    def value(record)
      reader.call(record, name)
    end
  end
end
