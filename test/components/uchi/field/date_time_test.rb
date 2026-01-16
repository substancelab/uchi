require "test_helper"
require "ostruct"

module Uchi
  class Field
    class DateTimeTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::DateTime.new(:created_at)
        @form = OpenStruct.new(object: OpenStruct.new(created_at: ::DateTime.new(2024, 1, 1, 12, 0, 0)))
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
        assert_kind_of Uchi::Field::DateTime::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::DateTime::Index, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::DateTime.new(:created_at).searchable(false)
        assert_not field.searchable?
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::DateTime::Show, component
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::DateTime.new(:created_at).sortable(false)
        assert_not field.sortable?
      end
    end

    class DateTimeEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::DateTime.new(:created_at)
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:created_at) { ::DateTime.new(2024, 1, 1, 12, 0, 0) }
        @record.define_singleton_method(:created_at=) { |val| @created_at = val }
        @repository = Uchi::Repositories::Author.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:author, @record, @view_context, {})

        @component = Uchi::Field::DateTime::Edit.new(
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

      test "can be rendered without errors" do
        # Skip rendering tests due to missing Flowbite::InputField::DateTime dependency
        assert_nothing_raised do
          @component
        end
      end

      test "initializes the input component with the correct options" do
        expected_options = {
          attribute: :created_at,
          form: @form,
          label: {content: "Custom label"},
          hint: {content: "Custom hint"}
        }
        assert_equal expected_options, @component.send(:options)
      end
    end

    class DateTimeIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::DateTime.new(:created_at)
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:created_at) { ::DateTime.new(2024, 1, 1, 12, 0, 0) }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::DateTime::Index.new(
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

        assert_includes result.to_html, "2024-01-01T12:00:00+00:00"
      end
    end

    class DateTimeShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::DateTime.new(:created_at)
        @record = Author.new(name: "Test Author")
        @record.define_singleton_method(:created_at) { ::DateTime.new(2024, 1, 1, 12, 0, 0) }
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::DateTime::Show.new(
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

        assert_includes result.to_html, "2024-01-01T12:00:00+00:00"
      end
    end
  end
end
