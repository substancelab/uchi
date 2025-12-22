# frozen_string_literal: true

module Uchi
  class Field
    module Configuration
      class Unset; end

      DEFAULT_READER = ->(record, field_name) { record&.public_send(field_name) }

      def initialize(*args)
        super
        @on = default_on
        @reader = DEFAULT_READER
        @searchable = default_searchable?
        @sortable = default_sortable?
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

      protected

      def default_on
        [:edit, :index, :show]
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
