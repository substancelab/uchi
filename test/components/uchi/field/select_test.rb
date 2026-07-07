require "test_helper"
require "ostruct"

module Uchi
  class Field
    class SelectTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({"fiction" => "Fiction", "nonfiction" => "Non-fiction"})
        @form = OpenStruct.new(object: OpenStruct.new(biography: "fiction"))
        @repository = Uchi::Repositories::Author.new
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options" do
        assert_equal [:edit, :index, :new, :show], @field.on
        assert_not @field.searchable?
        assert @field.sortable?
      end

      test "#edit_component returns an instance of Edit component" do
        component = @field.edit_component(form: @form, hint: "Custom hint", label: "Custom label", repository: @repository)
        assert_equal "Custom hint", component.hint
        assert_equal "Custom label", component.label
        assert_equal @field, component.field
        assert_equal @form, component.form
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Select::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Select::Index, component
      end

      test "#label_for returns the label for a known value" do
        assert_equal "Fiction", @field.label_for("fiction")
      end

      test "#label_for matches values regardless of Symbol vs String, like <select> does" do
        field = Uchi::Field::Select.new(:biography).options({fiction: "Fiction and stuff"})
        assert_equal "Fiction and stuff", field.label_for("fiction")
      end

      test "#label_for returns nil for an unknown value" do
        assert_nil @field.label_for("unknown")
      end

      test "#label_for returns nil for a nil value" do
        assert_nil @field.label_for(nil)
      end

      test "#label_for returns nil for a nil value even if an option is keyed by an empty string" do
        field = Uchi::Field::Select.new(:biography).options({"" => "Blank"})
        assert_nil field.label_for(nil)
      end

      test "#label_for finds the label for a value nested in a group" do
        field = Uchi::Field::Select.new(:biography).options({
          "Fiction" => {"fantasy" => "Fantasy"},
          "Non-fiction" => ["Biography"]
        })
        assert_equal "Fantasy", field.label_for("fantasy")
        assert_equal "Biography", field.label_for("Biography")
      end

      test "#grouped? returns false for a flat Hash" do
        assert_not @field.grouped?
      end

      test "#grouped? returns true when values are Hashes" do
        field = Uchi::Field::Select.new(:biography).options({
          "Fiction" => {"fantasy" => "Fantasy"}
        })
        assert field.grouped?
      end

      test "#grouped? returns false for an empty Hash" do
        assert_not Uchi::Field::Select.new(:biography).options({}).grouped?
      end

      test "#grouped? returns false when only some values are Hashes" do
        field = Uchi::Field::Select.new(:biography).options({
          "Fiction" => {"fantasy" => "Fantasy"},
          "fiction" => "Fiction"
        })
        assert_not field.grouped?
      end

      test "#options defaults to an empty hash" do
        assert_equal({}, Uchi::Field::Select.new(:biography).options)
      end

      test "#options returns the configured options" do
        assert_equal({"fiction" => "Fiction", "nonfiction" => "Non-fiction"}, @field.options)
      end

      test "#options given an Array uses each item as both value and label" do
        field = Uchi::Field::Select.new(:biography).options(["Fiction", "Non-fiction"])
        assert_equal({"Fiction" => "Fiction", "Non-fiction" => "Non-fiction"}, field.options)
      end

      test "#options given a Proc calls it and returns a Hash" do
        field = Uchi::Field::Select.new(:biography).options(-> { {"fiction" => "Fiction"} })
        assert_equal({"fiction" => "Fiction"}, field.options)
      end

      test "#options given a Proc returning an Array uses each item as both value and label" do
        field = Uchi::Field::Select.new(:biography).options(-> { ["Fiction", "Non-fiction"] })
        assert_equal({"Fiction" => "Fiction", "Non-fiction" => "Non-fiction"}, field.options)
      end

      test "#options given grouped options normalizes each group's Array values" do
        field = Uchi::Field::Select.new(:biography).options({
          "Fiction" => {"fantasy" => "Fantasy"},
          "Non-fiction" => ["Biography"]
        })
        assert_equal({
          "Fiction" => {"fantasy" => "Fantasy"},
          "Non-fiction" => {"Biography" => "Biography"}
        }, field.options)
      end

      test "#label_for only resolves options once across multiple calls" do
        calls = 0
        field = Uchi::Field::Select.new(:biography).options(-> {
          calls += 1
          {"fiction" => "Fiction", "nonfiction" => "Non-fiction"}
        })

        field.label_for("fiction")
        field.label_for("nonfiction")
        field.label_for("unknown")

        assert_equal 1, calls
      end

      test "#label_for re-resolves options after being reconfigured" do
        field = Uchi::Field::Select.new(:biography).options({"fiction" => "Fiction"})
        field.label_for("fiction")

        field.options({"fiction" => "Fiction, again"})

        assert_equal "Fiction, again", field.label_for("fiction")
      end

      test "#options given a Proc only calls it once across multiple reads" do
        calls = 0
        field = Uchi::Field::Select.new(:biography).options(-> {
          calls += 1
          {"fiction" => "Fiction"}
        })

        field.options
        field.grouped?
        field.label_for("fiction")

        assert_equal 1, calls
      end

      test "#options re-evaluates the Proc after being reconfigured" do
        calls = 0
        field = Uchi::Field::Select.new(:biography).options(-> {
          calls += 1
          {"fiction" => "Fiction"}
        })
        field.options

        field.options(-> {
          calls += 1
          {"fiction" => "Fiction, again"}
        })

        assert_equal "Fiction, again", field.label_for("fiction")
        assert_equal 2, calls
      end

      test "#options raises ArgumentError for an unsupported type" do
        field = Uchi::Field::Select.new(:biography).options("not a hash or array")
        assert_raises(ArgumentError) { field.options }
      end

      test "#options raises ArgumentError when a Proc returns an unsupported type" do
        field = Uchi::Field::Select.new(:biography).options(-> { "not a hash or array" })
        assert_raises(ArgumentError) { field.options }
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Select::Show, component
      end
    end

    class SelectEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({"fiction" => "Fiction", "nonfiction" => "Non-fiction"})
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:biography) { "fiction" }
        @record.define_singleton_method(:biography=) { |val| @biography = val }
        @repository = Uchi::Repositories::Author.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:author, @record, @view_context, {})

        @component = Uchi::Field::Select::Edit.new(
          field: @field,
          form: @form,
          hint: "Custom hint",
          label: "Custom label",
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Edit, @component
      end

      test "renders a select field with an option per configured value" do
        render_inline(@component)

        assert_selector("select[name='author[biography]']")
        assert_selector("option", text: "Fiction")
        assert_selector("option", text: "Non-fiction")
      end

      test "renders label with specified text" do
        render_inline(@component)

        assert_selector("label", text: "Custom label")
      end

      test "renders hint when provided" do
        render_inline(@component)

        assert_selector("p", text: "Custom hint")
      end

      test "#collection returns the configured options as label/value pairs" do
        assert_equal [["Fiction", "fiction"], ["Non-fiction", "nonfiction"]], @component.collection
      end

      test "initializes the input component with the correct options" do
        expected_options = {
          attribute: :biography,
          collection: [["Fiction", "fiction"], ["Non-fiction", "nonfiction"]],
          form: @form,
          label: {content: "Custom label"},
          hint: {content: "Custom hint"}
        }
        assert_equal expected_options, @component.send(:options)
      end
    end

    class SelectEditGroupedTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({
          "Fiction" => {"fantasy" => "Fantasy"},
          "Non-fiction" => ["Biography"]
        })
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:biography) { "fantasy" }
        @record.define_singleton_method(:biography=) { |val| @biography = val }
        @repository = Uchi::Repositories::Author.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:author, @record, @view_context, {})

        @component = Uchi::Field::Select::Edit.new(
          field: @field,
          form: @form,
          repository: @repository
        )
      end

      test "#collection returns the configured options grouped by label" do
        assert_equal [
          ["Fiction", [["Fantasy", "fantasy"]]],
          ["Non-fiction", [["Biography", "Biography"]]]
        ], @component.collection
      end

      test "renders optgroups" do
        render_inline(@component)

        assert_selector("optgroup[label='Fiction'] option", text: "Fantasy")
        assert_selector("optgroup[label='Non-fiction'] option", text: "Biography")
      end
    end

    class SelectEditMixedOptionsTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({
          "Fiction" => {"fantasy" => "Fantasy"},
          "fiction" => "Fiction"
        })
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:biography) { "fantasy" }
        @record.define_singleton_method(:biography=) { |val| @biography = val }
        @repository = Uchi::Repositories::Author.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:author, @record, @view_context, {})

        @component = Uchi::Field::Select::Edit.new(
          field: @field,
          form: @form,
          repository: @repository
        )
      end

      test "#collection flattens nested groups instead of rendering a Hash as a label" do
        assert_equal [["Fantasy", "fantasy"], ["Fiction", "fiction"]], @component.collection
      end

      test "renders plain options, not a Hash turned into a label" do
        render_inline(@component)

        assert_selector("option", text: "Fantasy")
        assert_selector("option", text: "Fiction")
        assert_no_selector("optgroup")
      end
    end

    class SelectIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({"fiction" => "Fiction", "nonfiction" => "Non-fiction"})
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:biography) { "fiction" }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Select::Index.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Index, @component
      end

      test "renders the label for the field's value" do
        result = render_inline(@component)

        assert_includes result.to_html, "Fiction"
      end
    end

    class SelectShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({"fiction" => "Fiction", "nonfiction" => "Non-fiction"})
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:biography) { "fiction" }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Select::Show.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Show, @component
      end

      test "renders the label for the field's value" do
        result = render_inline(@component)

        assert_includes result.to_html, "Fiction"
      end
    end

    class SelectShowSymbolOptionsTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({fiction: "Fiction and stuff"})
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:biography) { "fiction" }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Select::Show.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "renders the label for a Symbol-keyed option matching a String value" do
        result = render_inline(@component)

        assert_includes result.to_html, "Fiction and stuff"
      end
    end

    class SelectShowUnknownValueTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Select.new(:biography).options({"fiction" => "Fiction", "nonfiction" => "Non-fiction"})
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:biography) { "unsaved" }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Select::Show.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "renders nothing, since the saved value doesn't match any option" do
        result = render_inline(@component)

        assert_not_includes result.to_html, "Fiction"
        assert_not_includes result.to_html, "unsaved"
      end
    end
  end
end
