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

      # Returns the label to display for the given value, falling back to the
      # raw value itself if it isn't found among the configured options.
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
        self
      end

      private

      def flat_options
        resolved_options.each_with_object({}) { |(key, value), flat|
          value.is_a?(Hash) ? flat.merge!(value) : flat[key] = value
        }
      end

      def normalize(options)
        return options.to_h { |option| [option, option] } if options.is_a?(Array)
        return options unless options.is_a?(Hash)

        options.transform_values { |value| value.is_a?(Array) ? value.to_h { |option| [option, option] } : value }
      end

      def resolved_options
        normalize(@options.respond_to?(:call) ? @options.call : @options)
      end
    end
  end
end
