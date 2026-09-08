# frozen_string_literal: true

module Uchi
  # Provides a forward- and backwards compatible way of calling a proc.
  #
  # Expects `proc` to accept only keyword arguments and calls the proc with only
  # the keyword arguments it declares. Optional keyword arguments that are not
  # provided are left out, so the proc's own default applies. A proc accepting
  # `**kwargs` is called with all provided keyword arguments.
  #
  # If the proc requires a keyword argument that is not provided an
  # ArgumentError is raised.
  class CallWithFlexibleArguments
    attr_reader :proc

    def call(**kwargs)
      parameters = proc.parameters

      positional = parameters.find { |type, _name| [:req, :opt].include?(type) }
      if positional
        raise \
          ArgumentError,
          "Expected #{proc.inspect} to accept only keyword arguments, but " \
          "it declares positional parameter: #{positional.last}"
      end

      return proc.call(**kwargs) if parameters.any? { |type, _name| type == :keyrest }

      # Generate a list of arguments both included in the proc's parameters and
      # present in the provided keyword arguments. Optional keyword arguments
      # not present in kwargs are omitted, so the proc's default applies.
      arguments = parameters.filter_map do |type, name|
        if kwargs.key?(name)
          [name, kwargs[name]]
        elsif type == :keyreq
          raise \
            ArgumentError,
            "Missing required keyword argument: #{name} in #{proc.inspect}"
        end
      end

      proc.call(**arguments.to_h)
    end

    def initialize(proc)
      @proc = proc
    end
  end
end
