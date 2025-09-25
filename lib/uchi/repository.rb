# frozen_string_literal: true

require_relative "repository/routes"

module Uchi
  class Repository
    class << self
      # Returns all defined Uchi::Repository classes
      def all
        Uchi::Repositories.constants.map { |const_name|
          Uchi::Repositories.const_get(const_name)
        }
      end

      # Returns the repository for the given model, or nil if none is found.
      def for_model(model)
        if model.is_a?(String) || model.is_a?(Symbol)
          # TODO: Is this not a potential security issue?
          model = model.to_s.constantize
        end
        all.find { |repository| repository.model == model }
      end

      # Returns the model class this repository manages.
      def model
        @model ||= name.demodulize.constantize
      end
    end

    # Returns a new, unsaved instance of the model this repository manages.
    def build(attributes = {})
      model.new(attributes)
    end

    # Returns the "name" of the controller that handles requests for this
    # repository. Note that this is different from the controllers class name
    # and is intended for generating URLs.
    def controller_name
      model_param_key.pluralize
    end

    def default_sort_order
      SortOrder.new(:id, :asc)
    end

    # Returns an array of fields to show on the edit page.
    def fields_for_edit
      fields.select { |field| field.on.include?(:edit) }
    end

    # Returns an array of fields to show on the index page.
    def fields_for_index
      fields.select { |field| field.on.include?(:index) }
    end

    # Returns an array of fields to show on the show page.
    def fields_for_show
      fields.select { |field| field.on.include?(:show) }
    end

    def find_all(scope: model.all, sort_order: default_sort_order)
      scope ||= model.all
      query = scope.includes(includes)
      apply_sort_order(query, sort_order)
    end

    def find(id)
      model.find(id)
    end

    # Returns the list of associations to include when querying for records.
    #
    # See
    # https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes
    # for further details.
    def includes
      []
    end

    def model
      self.class.model
    end

    def model_param_key
      model.model_name.param_key
    end

    # Returns an instance of Uchi::Repository::Routes for this repository,
    # which can be used to generate paths and URLs.
    #
    # @return [Uchi::Repository::Routes]
    def routes
      @routes ||= Routes.new(self)
    end

    # Returns the title to show for a given record
    def title(record)
      record.to_s
    end

    # Provides access to translation helpers specific to this repository.
    def translate
      @translate ||= Translate.new(repository: self)
    end

    private

    def apply_sort_order(query, sort_order)
      field_to_sort_by = fields.find { |field| field.name == sort_order.name }
      return query unless field_to_sort_by

      if field_to_sort_by.sortable.respond_to?(:call)
        field_to_sort_by.sortable.call(query, sort_order.direction)
      else
        sort_order.apply(query)
      end
    end
  end
end
