# frozen_string_literal: true

require "uchi/call_with_flexible_arguments"

require_relative "repository/routes"

module Uchi
  class Repository
    class << self
      # Returns all defined Uchi::Repository classes
      def all
        Uchi::Repositories.constants.sort.map { |const_name|
          Uchi::Repositories.const_get(const_name)
        }
      end

      # Returns true if at least one repository has a searchable field.
      #
      # @return [Boolean]
      def any_searchable?
        all.any? { |repository_class| repository_class.new.searchable? }
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

    attr_accessor :context

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
      SortOrder.new(model.primary_key.to_sym, :asc)
    end

    # Returns an array of fields to show on the edit page.
    #
    # @param record [Object, nil] The record being edited. When provided, fields with a
    #   visibility condition are filtered by it. When omitted, all edit fields are returned.
    # @return [Array<Uchi::Field>]
    def fields_for_edit(record: nil)
      return fields_for(:edit) if record.nil?

      fields_for(:edit).select { |field| field.visible_for?(record) }
    end

    # Returns an array of fields to show on the index page.
    #
    # @return [Array<Uchi::Field>]
    def fields_for_index
      fields_for(:index)
    end

    # Returns an array of fields to show on the new page.
    #
    # @param record [Object, nil] The record being created. When provided, fields with a
    #   visibility condition are filtered by it. When omitted, all new fields are returned.
    # @return [Array<Uchi::Field>]
    def fields_for_new(record: nil)
      return fields_for(:new) if record.nil?

      fields_for(:new).select { |field| field.visible_for?(record) }
    end

    # Returns an array of fields to show on the show page.
    #
    # @param record [Object, nil] The record being shown. When provided, fields with a
    #   visibility condition are filtered by it. When omitted, all show fields are returned.
    # @return [Array<Uchi::Field>]
    def fields_for_show(record: nil)
      return fields_for(:show) if record.nil?

      fields_for(:show).select { |field| field.visible_for?(record) }
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
      model.where(model.primary_key => ids)
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

    def initialize(context: nil)
      @context = context || build_default_context
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
    # 1. `title`
    # 2. `name`
    # 3. `to_s`
    #
    # You can override this method in your repository subclass to provide
    # custom logic.
    def title(record)
      return nil unless record

      [:title, :name, :to_s].each do |method|
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
      search = search&.strip
      return query if search.blank?
      return query if searchable_fields.empty?

      lambda_fields, plain_fields = searchable_fields.partition { |field| field.searchable.respond_to?(:call) }

      conditions = lambda_fields.map do |field|
        id_in(
          Uchi::CallWithFlexibleArguments.new(field.searchable).call(
            context: context,
            query: query,
            term: search
          )
        )
      end
      conditions += plain_field_conditions(plain_fields, search)

      query.where(conditions.inject(:or))
    end

    def build_default_context
      Uchi::Context.new
    end

    # Wraps a scope in an `id IN (subquery)` Arel condition, so it can be
    # combined with other search conditions without running its own query.
    def id_in(scope)
      primary_key = model.primary_key.to_sym
      model.arel_table[primary_key].in(scope.select(primary_key).arel)
    end

    def plain_field_conditions(fields, search)
      fields.map { |field|
        arel_field = model.arel_table[field.name]
        Arel::Nodes::NamedFunction.new(
          "CAST",
          [arel_field.as(Arel::Nodes::SqlLiteral.new(cast_to_text_type))]
        ).matches("%#{search}%")
      }
    end

    # Returns the CAST target type used to coerce non-text columns to text
    # for substring search. MySQL doesn't support CAST(... AS VARCHAR) or
    # CAST(... AS TEXT); it requires CHAR. Postgres and SQLite accept TEXT,
    # but Postgres' bare CHAR truncates to a single character, so it can't be
    # used as a shared default across adapters.
    def cast_to_text_type
      case model.connection.adapter_name
      when /mysql/i
        "CHAR"
      else
        "TEXT"
      end
    end

    def apply_sort_order(query, sort_order)
      field_to_sort_by = fields.find { |field| field.name == sort_order.column }
      return query unless field_to_sort_by

      if field_to_sort_by.sortable.respond_to?(:call)
        Uchi::CallWithFlexibleArguments
          .new(field_to_sort_by.sortable)
          .call(
            context: context,
            direction: sort_order.direction,
            query: query
          )
      else
        sort_order.apply(query)
      end
    end

    # Returns an array of fields to show for the given action.
    #
    # @param action [Symbol] The action to get fields for. One of :index, :show,
    # :new, :edit.
    #
    # @return [Array<Uchi::Field>]
    def fields_for(action)
      fields_with_repository.select { |field| field.on.include?(action) }
    end

    def fields_with_repository
      fields.each { |field| field.repository = self }
    end

    def searchable_fields
      @searchable_fields ||= fields.select { |field| field.searchable? }
    end
  end
end
