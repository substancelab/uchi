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

      test "#label_for falls back to the raw value for an unknown value" do
        assert_equal "unknown", @field.label_for("unknown")
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
  end
end
