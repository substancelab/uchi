# frozen_string_literal: true

module Uchi
  # Provides a forward- and backwards compatible way of calling a proc.
  #
  # Expects `proc` to accept only keyword arguments and calls the proc with only
  # the keyword arguments it declares.
  #
  # If the proc expects a keyword argument that is not provided to call an
  # ArgumentError is raised.
  class CallWithFlexibleArguments
    attr_reader :proc

    def call(**kwargs)
      parameters = proc.parameters

      # Generate a list of arguments both included in the proc's parameters and
      # present in the provided keyword arguments.
      arguments = parameters.map do |type, name|
        if kwargs.key?(name)
          [name, kwargs[name]]
        else
          raise \
            ArgumentError,
            "Unsupported keyword argument: #{name} in #{proc.inspect}"
        end
      end.compact

      proc.call(**arguments.to_h)
    end

    def initialize(proc)
      @proc = proc
    end
  end
end
