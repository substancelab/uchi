# frozen_string_literal: true

module Uchi
  class Field
    class Select < Field
      class Edit < Uchi::Field::Base::Edit
        def collection
          if field.grouped?
            field.options.map { |group, group_options| [group, group_options.map { |value, label| [label, value] }] }
          else
            field.options.map { |value, label| [label, value] }
          end
        end

        private

        def options
          options = {
            attribute: field.name,
            collection: collection,
            form: form,
            label: {content: label}
          }
          options[:hint] = {content: hint} if hint.present?
          options
        end
      end

      class Index < Uchi::Field::Base::Index
      end

      class Show < Uchi::Field::Base::Show
      end

      # Returns true if the configured options are grouped, ie. a Hash whose
      # values are themselves Hashes of options.
      def grouped?
        resolved_options.values.first.is_a?(Hash)
      end

      def initialize(name)
        super
        @options = {}
      end

      # Returns the label to display for the given value, or nil if the value
      # doesn't match any of the configured options.
      #
      # Values are compared using their string representation, matching how
      # a `<select>` element compares its options' values against the
      # persisted attribute value.
      def label_for(value)
        _key, label = flat_options.find { |option_value, _label| option_value.to_s == value.to_s }
        label
      end

      # Sets or gets the options to choose between.
      #
      # When called with an argument, sets the options and returns self for
      # chaining. When called without arguments, returns the current options,
      # resolved to a Hash.
      #
      # @param options [Hash, Array, Proc] A hash mapping stored values to
      #   their human-readable labels. An array can be given instead, in which
      #   case each item is used as both the stored value and its label. A
      #   proc can also be given; it's called with no arguments and should
      #   return a Hash or an Array as described above.
      #
      #   To group options, pass a Hash whose values are themselves a Hash or
      #   Array of options, keyed by the group label.
      # @return [self, Hash] Returns self for method chaining when setting,
      #   or the options hash when getting
      #
      # @example Setting with a Hash
      #   Field::Select.new(:size).options({s: "Small", m: "Medium", l: "Large"})
      #
      # @example Setting with an Array
      #   Field::Select.new(:size).options(["Small", "Medium", "Large"])
      #
      # @example Setting with a Proc
      #   Field::Select.new(:size).options(-> { Size.pluck(:key, :name).to_h })
      #
      # @example Setting grouped options
      #   Field::Select.new(:size).options({
      #     "Letters" => {s: "Small", m: "Medium", l: "Large"},
      #     "Numbers" => ["32", "34", "36"]
      #   })
      #
      # @example Getting
      #   field.options # => {s: "Small", m: "Medium", l: "Large"}
      def options(options = Configuration::Unset)
        return resolved_options if options == Configuration::Unset

        @options = options
        @resolved_options = nil
        @flat_options = nil
        self
      end

      private

      # Resolves and memoizes the options as a flat value => label Hash,
      # merging grouped options together. Memoized for the same reason as
      # #resolved_options - see there for details.
      #
      # When the same value appears in more than one group, the first
      # matching label wins - matching how a browser's `<select>` element
      # only ever selects the first option with a matching value.
      def flat_options
        @flat_options ||= resolved_options.each_with_object({}) { |(key, value), flat|
          if value.is_a?(Hash)
            value.each { |group_key, group_label| flat[group_key] = group_label unless flat.key?(group_key) }
          else
            flat[key] = value unless flat.key?(key)
          end
        }
      end

      def normalize(options)
        case options
        when Array
          options.to_h { |option| [option, option] }
        when Hash
          options.transform_values { |value| value.is_a?(Array) ? value.to_h { |option| [option, option] } : value }
        else
          raise ArgumentError, "Field::Select options must be a Hash, an Array, or a Proc returning one of those, got #{options.class}"
        end
      end

      # Resolves and memoizes the configured options. Memoized so that a Proc
      # given to #options is only called once per field instance, even though
      # #options, #grouped?, and #label_for are all called multiple times
      # while rendering a single page (e.g. once per row on an index page).
      # The memo is cleared whenever #options is called with a new value.
      def resolved_options
        @resolved_options ||= normalize(@options.respond_to?(:call) ? @options.call : @options)
      end
    end
  end
end
