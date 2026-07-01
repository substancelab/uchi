# frozen_string_literal: true

module Uchi
  class Field
    module Configuration
      class Unset; end

      DEFAULT_READER = ->(record, field_name) { record&.public_send(field_name) }
      DEFAULT_VISIBLE = ->(_record) { true }

      def initialize(*args)
        super
        @on = default_on
        @reader = DEFAULT_READER
        @searchable = default_searchable?
        @visible = DEFAULT_VISIBLE
        @sortable = default_sortable?
      end

      # Sets or gets the model attribute name this field reads from.
      #
      # When called with an argument, sets the attribute and returns self for chaining.
      # When called without arguments, returns the configured attribute name, or falls
      # back to the field's name if no attribute has been configured.
      #
      # @param attribute_name [Symbol, String] The name of the model attribute
      # @return [self, Symbol] Returns self for method chaining when setting,
      #   or the attribute name when getting
      #
      # @example Setting
      #   Field::BelongsTo.new(:company).attribute(:owner)
      #
      # @example Getting
      #   field.attribute # => :company (default) or :owner (if explicitly set)
      def attribute(attribute_name = Configuration::Unset)
        return @attribute || name if attribute_name == Configuration::Unset

        @attribute = attribute_name.to_sym
        self
      end

      # Sets or gets which actions this field should appear on.
      #
      # When called with arguments, sets the actions and returns self for chaining.
      # When called without arguments, returns the current actions.
      #
      # @param actions [Array<Symbol>] The actions where this field should appear
      #   (e.g., :index, :show, :new, :edit)
      # @return [self, Array<Symbol>] Returns self for method chaining when setting,
      #   or the actions array when getting
      #
      # @example Setting
      #   Field::Number.new(:id).on(:index, :show)
      #
      # @example Getting
      #   field.on # => [:index, :show]
      def on(*actions)
        return @on if actions.empty?

        @on = actions.flatten
        self
      end

      # Sets or gets a custom reader for this field.
      #
      # When called with an argument, sets the reader and returns self for chaining.
      # When called without arguments, returns the current reader.
      #
      # @param reader_proc [Proc, nil] A callable that reads the value from a record.
      #   The proc receives the model and field name, and should return the value.
      # @return [self, Proc] Returns self for method chaining when setting,
      #   or the reader proc when getting
      #
      # @example Setting
      #   Field::String.new(:full_name).reader(->(record, field_name) {
      #     "#{record.first_name} #{record.last_name}"
      #   })
      #
      # @example Getting
      #   field.reader # => #<Proc...>
      def reader(reader_proc = nil)
        return @reader if reader_proc.nil? && !block_given?

        @reader = reader_proc || Proc.new
        self
      end

      # Sets or gets whether this field is searchable.
      #
      # When called with an argument, sets searchable and returns self for chaining.
      # When called without arguments, returns whether the field is searchable.
      #
      # @param value [Boolean, nil] Whether the field is searchable in index views.
      #   Defaults to false for most fields, except text-based fields.
      # @return [self, Boolean] Returns self for method chaining when setting,
      #   or boolean when getting
      #
      # @example Setting
      #   Field::String.new(:password).searchable(false)
      #   Field::Number.new(:id).searchable(true)
      def searchable(value = Configuration::Unset)
        return @searchable if value == Configuration::Unset

        @searchable = value
        self
      end

      # Returns true if the field is searchable and should be included in the
      # query when a search term has been entered.
      def searchable?
        return default_searchable? if @searchable.nil?

        !!@searchable
      end

      # Sets or gets a conditional proc that determines whether this field should
      # be visible for a given record.
      #
      # When called with a proc argument, sets the visibility condition and returns
      # self for chaining. When called without arguments, returns the current proc.
      #
      # @param visible_proc [Proc] A callable that receives the record and returns
      #   a boolean indicating whether the field should be visible.
      #   Raises ArgumentError for non-callables.
      # @return [self, Proc] Returns self for method chaining when setting,
      #   or the current proc when getting
      #
      # @example Setting
      #   Field::String.new(:id).visible(lambda { |record| record.id.even? })
      #
      # @example Getting
      #   field.visible # => #<Proc...>
      def visible(visible_proc = Configuration::Unset)
        return @visible if visible_proc == Configuration::Unset

        raise ArgumentError, "visible must be callable" unless visible_proc.respond_to?(:call)

        @visible = visible_proc
        self
      end

      # Sets or gets whether and how this field is sortable.
      #
      # When called with an argument, sets sortable and returns self for chaining.
      # When called without arguments, returns the sortable value.
      #
      # @param value [Boolean, Proc, Symbol] Whether the field is sortable. Pass true/false
      #   for simple sorting, or a lambda that receives the query and direction
      #   and returns an ActiveRecord::Relation for custom sorting.
      # @return [self, Boolean, Proc] Returns self for method chaining when setting,
      #   or the sortable value when getting
      #
      # @example Setting with boolean
      #   Field::Number.new(:calculated_sum).sortable(false)
      #
      # @example Setting with lambda
      #   Field::Number.new(:users_count).sortable(lambda { |query, direction|
      #     query.joins(:users).group(:id).order("COUNT(users.id) #{direction}")
      #   })
      #
      # @example Getting
      #   field.sortable # => true
      def sortable(value = Configuration::Unset)
        return @sortable if value == Configuration::Unset

        @sortable = value
        self
      end

      # Returns true if the field is sortable
      def sortable?
        return default_sortable? if @sortable.nil?

        !!@sortable
      end

      # Returns whether this field should be visible for the given record.
      #
      # Calls the visible proc with the record. Defaults to DEFAULT_VISIBLE,
      # which always returns true.
      #
      # @param record [Object] The record to check visibility for
      # @return [Boolean] Whether the field should be visible
      def visible_for?(record)
        !!@visible.call(record)
      end

      protected

      def default_on
        [:edit, :index, :new, :show]
      end

      def default_searchable?
        false
      end

      def default_sortable?
        true
      end
    end
  end
end
