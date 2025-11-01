require "test_helper"
require "ostruct"

module Uchi
  class Field
    class TextTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::Text.new(:biography)
        @form = OpenStruct.new(object: OpenStruct.new(biography: "Test Biography"))
        @repository = Uchi::Repositories::Author.new
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options" do
        assert_equal [:edit, :index, :show], @field.on
        assert @field.searchable?
        assert @field.sortable?
      end

      test "#edit_component returns an instance of Edit component" do
        component = @field.edit_component(form: @form, hint: "Custom hint", label: "Custom label", repository: @repository)
        assert_equal "Custom hint", component.hint
        assert_equal "Custom label", component.label
        assert_equal @field, component.field
        assert_equal @form, component.form
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Text::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Text::Index, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::Text.new(:biography).searchable(false)
        assert_not field.searchable?
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Text::Show, component
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::Text.new(:biography).sortable(false)
        assert_not field.sortable?
      end
    end

    class TextEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Text.new(:biography)
        @record = Author.new(name: "J.R.R Tolkien", biography: "Famous author")
        @repository = Uchi::Repositories::Author.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:author, @record, @view_context, {})

        @component = Uchi::Field::Text::Edit.new(
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

      test "renders a textarea field with the field content" do
        render_inline(@component)

        assert_selector("textarea[name='author[biography]']", text: "Famous author")
      end

      test "renders label with specified text" do
        render_inline(@component)

        assert_selector("label[for='author_biography']", text: "Custom label")
      end

      test "renders hint when provided" do
        render_inline(@component)

        assert_selector("p[id=author_biography_hint]", text: "Custom hint")
      end

      test "initializes the input component with the correct options" do
        expected_options = {
          attribute: :biography,
          form: @form,
          label: {content: "Custom label"},
          hint: {content: "Custom hint"}
        }
        assert_equal expected_options, @component.send(:options)
      end
    end

    class TextIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Text.new(:biography)
        @record = Author.new(name: "J.R.R Tolkien", biography: "Famous author of The Lord of the Rings")
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Text::Index.new(
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

        assert_includes result.to_html, "Famous author of The Lord of the Rings"
      end
    end

    class TextShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Text.new(:biography)
        @record = Author.new(name: "J.R.R Tolkien", biography: "Famous author of The Lord of the Rings")
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::Text::Show.new(
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

        assert_includes result.to_html, "Famous author of The Lord of the Rings"
      end
    end
  end
end
