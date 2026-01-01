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

      # Returns the "name" of the controller that handles requests for this
      # repository. Note that this is different from the controllers class name
      # and is intended for generating URLs.
      def controller_name
        model_param_key.pluralize
      end

      # Returns the repository for the given model, or nil if none is found.
      def for_model(model)
        all.find { |repository| repository.model.to_s == model.to_s }
      end

      # Returns the model class this repository manages.
      def model
        @model ||= name.demodulize.constantize
      end

      def model_param_key
        model.model_name.param_key
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
      self.class.controller_name
    end

    def default_sort_order
      SortOrder.new(:id, :asc)
    end

    # Returns an array of fields to show on the edit page.
    def fields_for_edit
      fields.select { |field| field.on.include?(:edit) }.each { |field| field.repository = self }
    end

    # Returns an array of fields to show on the index page.
    def fields_for_index
      fields.select { |field| field.on.include?(:index) }.each { |field| field.repository = self }
    end

    # Returns an array of fields to show on the show page.
    def fields_for_show
      fields.select { |field| field.on.include?(:show) }.each { |field| field.repository = self }
    end

    def find_all(search: nil, scope: model.all, sort_order: default_sort_order)
      scope ||= model.all
      query = scope.includes(includes)
      query = apply_search(query, search)
      apply_sort_order(query, sort_order)
    end

    # Finds multiple records by their IDs. If a record is not found, it is
    # ignored.
    #
    # @param ids [Array<Integer>] The IDs of the records to find
    #
    # @return [ActiveRecord::Relation] The found records
    def find_many(ids)
      model.where(id: ids)
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

    # Returns the list of actions available for this repository.
    #
    # Actions are instances of Uchi::Action subclasses that can be executed
    # on one or more records.
    #
    # Example:
    #   def actions
    #     [PublishPost.new, ExportToCsv.new]
    #   end
    #
    # @return [Array<Uchi::Action>]
    def actions
      []
    end

    def model
      self.class.model
    end

    def model_param_key
      self.class.model_param_key
    end

    # Returns an instance of Uchi::Repository::Routes for this repository,
    # which can be used to generate paths and URLs.
    #
    # @return [Uchi::Repository::Routes]
    def routes
      @routes ||= Routes.new(self)
    end

    # Returns true if this repository has at least one searchable field.
    #
    # @return [Boolean]
    def searchable?
      searchable_fields.any?
    end

    # Returns the title to show for a given record. By default, this method
    # returns the value of the first of the following methods that exist:
    #
    # 1. `name`
    # 2. `title`
    # 3. `to_s`
    #
    # You can override this method in your repository subclass to provide
    # custom logic.
    def title(record)
      return nil unless record

      [:name, :title, :to_s].each do |method|
        if record.respond_to?(method)
          return record.public_send(method)
        end
      end
    end

    # Provides access to translation helpers specific to this repository.
    def translate
      @translate ||= Translate.new(repository: self)
    end

    private

    def apply_search(query, search)
      return query unless search.present?
      return query if searchable_fields.empty?

      search = search.strip
      conditions = searchable_fields.map { |field|
        arel_field = model.arel_table[field.name]
        Arel::Nodes::NamedFunction.new(
          "CAST",
          [arel_field.as(Arel::Nodes::SqlLiteral.new("VARCHAR"))]
        ).matches("%#{search}%")
      }
      query.where(conditions.inject(:or))
    end

    def apply_sort_order(query, sort_order)
      field_to_sort_by = fields.find { |field| field.name == sort_order.name }
      return query unless field_to_sort_by

      if field_to_sort_by.sortable.respond_to?(:call)
        field_to_sort_by.sortable.call(query, sort_order.direction)
      else
        sort_order.apply(query)
      end
    end

    def searchable_fields
      @searchable_fields ||= fields.select { |field| field.searchable? }
    end
  end
end
