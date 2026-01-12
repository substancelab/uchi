require "test_helper"
require "ostruct"

module Uchi
  class Field
    class NestedManyTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::NestedMany.new(:titles)
        @form = OpenStruct.new(object: Book.new)
        @repository = Uchi::Repositories::Book.new
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options specific to NestedMany field" do
        assert_not @field.searchable?
        assert @field.sortable?
      end

      test "initializes with empty nested_fields" do
        assert_equal [], @field.nested_fields
      end

      test "#fields configures nested fields with Field instances" do
        field = Uchi::Field::NestedMany.new(:titles).fields(
          Field::String.new(:title),
          Field::String.new(:locale)
        )
        assert_equal 2, field.nested_fields.size
        assert_kind_of Field::String, field.nested_fields[0]
        assert_equal :title, field.nested_fields[0].name
        assert_kind_of Field::String, field.nested_fields[1]
        assert_equal :locale, field.nested_fields[1].name
      end

      test "#fields configures nested fields with array" do
        field = Uchi::Field::NestedMany.new(:titles).fields([
          Field::String.new(:title),
          Field::String.new(:locale)
        ])
        assert_equal 2, field.nested_fields.size
      end

      test "#fields returns nested_fields when called without arguments" do
        field = Uchi::Field::NestedMany.new(:titles).fields(
          Field::String.new(:title),
          Field::String.new(:locale)
        )
        assert_equal field.nested_fields, field.fields
      end

      test "#fields raises error for non-Field instances" do
        error = assert_raises(ArgumentError) do
          Uchi::Field::NestedMany.new(:titles).fields(:title, :language)
        end
        assert_match(/expects Uchi::Field instances/, error.message)
      end

      test "#param_key returns nested attributes key" do
        assert_equal :titles_attributes, @field.param_key
      end

      test "#permitted_param returns nested hash structure" do
        field = Uchi::Field::NestedMany.new(:titles).fields(
          Field::String.new(:title),
          Field::String.new(:locale)
        )
        expected = {
          titles_attributes: [:id, :_destroy, :title, :locale]
        }
        assert_equal expected, field.permitted_param
      end

      test "#permitted_param includes only id and _destroy when no fields configured" do
        expected = {
          titles_attributes: [:id, :_destroy]
        }
        assert_equal expected, @field.permitted_param
      end

      test "#group_as returns :associations" do
        assert_equal :associations, @field.group_as(:show)
        assert_equal :associations, @field.group_as(:edit)
      end

      test "#edit_component returns an instance of Edit component" do
        field = Uchi::Field::NestedMany.new(:titles).fields(Field::String.new(:title))
        component = field.edit_component(
          form: @form,
          hint: "Custom hint",
          label: "Custom label",
          repository: @repository
        )
        assert_equal "Custom hint", component.hint
        assert_equal "Custom label", component.label
        assert_equal field, component.field
        assert_equal @form, component.form
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::NestedMany::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::NestedMany::Index, component
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::NestedMany::Show, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::NestedMany.new(:titles).searchable(false)
        assert_not field.searchable?
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::NestedMany.new(:titles).sortable(false)
        assert_not field.sortable?
      end
    end

    class NestedManyEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::NestedMany.new(:titles).fields(
          Field::String.new(:title),
          Field::String.new(:locale)
        )
        @book = Book.new(original_title: "The Hobbit")
        @repository = Uchi::Repositories::Book.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:book, @book, @view_context, {})

        @component = Uchi::Field::NestedMany::Edit.new(
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

      test "#associated_records returns empty array for new record" do
        assert_equal [], @component.associated_records
      end

      test "#attribute_name returns param_key" do
        assert_equal :titles_attributes, @component.attribute_name
      end

      test "#reflection returns association reflection" do
        reflection = @component.reflection
        assert_not_nil reflection
        assert_equal :titles, reflection.name
      end
    end

    class NestedManyIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::NestedMany.new(:titles).fields(Field::String.new(:title))
        @book = Book.new(original_title: "The Hobbit")
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::NestedMany::Index.new(
          field: @field,
          record: @book,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Index, @component
      end
    end

    class NestedManyShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::NestedMany.new(:titles).fields(Field::String.new(:title))
        @book = Book.new(original_title: "The Hobbit")
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::NestedMany::Show.new(
          field: @field,
          record: @book,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Show, @component
      end

      test "#associated_records returns empty array for new record" do
        assert_equal [], @component.associated_records
      end

      test "#reflection returns association reflection" do
        reflection = @component.reflection
        assert_not_nil reflection
        assert_equal :titles, reflection.name
      end
    end
  end
end
