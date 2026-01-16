require "test_helper"
require "ostruct"

module Uchi
  class Field
    class BooleanTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::Boolean.new(:active)
        @form = OpenStruct.new(object: OpenStruct.new(active: true))
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
        assert_kind_of Uchi::Field::Boolean::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Boolean::Index, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::Boolean.new(:active).searchable(false)
        assert_not field.searchable?
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Boolean::Show, component
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::Boolean.new(:active).sortable(false)
        assert_not field.sortable?
      end
    end

    class BooleanEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Boolean.new(:active)
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:active) { true }
        @record.define_singleton_method(:active=) { |val| @active = val }
        @repository = Uchi::Repositories::Author.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:author, @record, @view_context, {})

        @component = Uchi::Field::Boolean::Edit.new(
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

      test "renders a checkbox field with the field content" do
        render_inline(@component)

        assert_selector("input[type='checkbox'][name='author[active]']")
      end

      test "renders label with specified text" do
        render_inline(@component)

        assert_selector("label", text: "Custom label")
      end

      test "renders hint when provided" do
        render_inline(@component)

        assert_selector("p", text: "Custom hint")
      end

      test "initializes the input component with the correct options" do
        expected_options = {
          attribute: :active,
          form: @form,
          label: {content: "Custom label"},
          hint: {content: "Custom hint"}
        }
        assert_equal expected_options, @component.send(:options)
      end
    end

    class BooleanIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Boolean.new(:active)
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:active) { true }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Boolean::Index.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Index, @component
      end

      test "renders the field content" do
        result = render_inline(@component)

        assert_includes result.to_html, "true"
      end
    end

    class BooleanShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Boolean.new(:active)
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:active) { true }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Boolean::Show.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Show, @component
      end

      test "renders the field content" do
        result = render_inline(@component)

        assert_includes result.to_html, "true"
      end
    end
  end
end
