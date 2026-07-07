# frozen_string_literal: true

module Uchi
  class Field
    class Select < Field
      class Edit < Uchi::Field::Base::Edit
        def collection
          field.options.map { |value, label| [label, value] }
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

      def initialize(name)
        super
        @options = {}
      end

      # Returns the label to display for the given value, falling back to the
      # raw value itself if it isn't found among the configured options.
      def label_for(value)
        options.fetch(value, value)
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
      # @example Getting
      #   field.options # => {s: "Small", m: "Medium", l: "Large"}
      def options(options = Configuration::Unset)
        return resolved_options if options == Configuration::Unset

        @options = options
        self
      end

      private

      def resolved_options
        options = @options.respond_to?(:call) ? @options.call : @options
        options.is_a?(Array) ? options.to_h { |option| [option, option] } : options
      end
    end
  end
end
