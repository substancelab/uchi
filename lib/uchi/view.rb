# frozen_string_literal: true

module Uchi
  # Represents a view/action a field or resource can appear on, e.g. :index,
  # :show, :new, :edit. Behaves like the underlying Symbol for equality,
  # hashing and array membership, so existing code comparing against plain
  # symbols keeps working.
  #
  # @example
  #   Uchi::View.new(:show) == :show # => true
  #   [Uchi::View.new(:edit)].include?(:edit) # => true
  class View
    NAMES = [:edit, :index, :new, :show].freeze

    attr_reader :name

    def initialize(name)
      @name = name.is_a?(View) ? name.name : name.to_sym
      raise ArgumentError, "unknown view: #{@name.inspect}" unless NAMES.include?(@name)
    end

    def ==(other)
      name == self.class.name_of(other)
    end
    alias_method :eql?, :==

    def hash
      name.hash
    end

    def inspect
      "#<Uchi::View #{name.inspect}>"
    end

    def to_s
      name.to_s
    end

    def to_sym
      name
    end

    def edit?
      name == :edit
    end

    def index?
      name == :index
    end

    def new?
      name == :new
    end

    def show?
      name == :show
    end

    class << self
      def name_of(value)
        value.is_a?(View) ? value.name : value.to_sym
      end
    end
  end
end
