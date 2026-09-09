# frozen_string_literal: true

module Uchi
  # Represents a view/action a field or resource can appear on, e.g. :index,
  # :show, :new, :edit.
  #
  # Uchi::View behaves like the underlying Symbol for equality, hashing and
  # array membership.
  #
  # @example Uchi::View.new(:show) == :show # => true
  #   [Uchi::View.new(:edit)].include?(:edit) # => true
  class View
    NAMES = [:edit, :index, :new, :show].freeze

    attr_reader :name

    def initialize(name)
      @name = name.is_a?(View) ? name.name : name.to_sym
      raise ArgumentError, "unknown view: #{@name.inspect}" unless NAMES.include?(@name)
    end

    def ==(other)
      return name == other if other.is_a?(Symbol)
      return name == other.name if other.is_a?(self.class)

      false
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
  end
end
