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
      # chaining. When called without arguments, returns the current options.
      #
      # @param options [Hash] A hash mapping stored values to their
      #   human-readable labels.
      # @return [self, Hash] Returns self for method chaining when setting,
      #   or the options hash when getting
      #
      # @example Setting
      #   Field::Select.new(:size).options({s: "Small", m: "Medium", l: "Large"})
      #
      # @example Getting
      #   field.options # => {s: "Small", m: "Medium", l: "Large"}
      def options(options = Configuration::Unset)
        return @options if options == Configuration::Unset

        @options = options
        self
      end
    end
  end
end
