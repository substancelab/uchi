require "test_helper"
require "ostruct"

module Uchi
  class Field
    class HasAndBelongsToManyTest < ActiveSupport::TestCase
      def setup
        @record = Book.new
        @form = OpenStruct.new(object: @record)

        @repository = Uchi::Repositories::Book.new
        @field = Uchi::Field::HasAndBelongsToMany.new(:authors)
        @field.repository = @repository
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options specific to HasAndBelongsToMany field" do
        assert_not @field.searchable?
        assert @field.sortable?
      end

      test "has custom collection_query" do
        custom_query = ->(query) { query.where(published: true) }
        field = Uchi::Field::HasAndBelongsToMany.new(:categories).collection_query(custom_query)
        assert_equal custom_query, field.collection_query
      end

      test "uses default collection_query" do
        assert_equal Uchi::Field::HasAndBelongsToMany::DEFAULT_COLLECTION_QUERY, @field.collection_query
      end

      test "#param_key returns foreign key name" do
        assert_equal :author_ids, @field.param_key
      end

      test "#permitted_param returns key for strong parameters" do
        assert_equal({author_ids: []}, @field.permitted_param)
      end

      test "#group_as returns :associations" do
        assert_equal :associations, @field.group_as(:show)
        assert_equal :associations, @field.group_as(:edit)
      end

      test "#edit_component returns an instance of Edit component" do
        component = @field.edit_component(form: @form, hint: "Custom hint", label: "Custom label", repository: @repository)
        assert_equal "Custom hint", component.hint
        assert_equal "Custom label", component.label
        assert_equal @field, component.field
        assert_equal @form, component.form
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::HasAndBelongsToMany::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::HasAndBelongsToMany::Index, component
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::HasAndBelongsToMany::Show, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::HasAndBelongsToMany.new(:categories).searchable(false)
        assert_not field.searchable?
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::HasAndBelongsToMany.new(:categories).sortable(false)
        assert_not field.sortable?
      end
    end

    class HasAndBelongsToManyEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::HasAndBelongsToMany.new(:categories)
        @book = Book.new(original_title: "The Hobbit")
        @repository = Uchi::Repositories::Book.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:book, @book, @view_context, {})

        @component = Uchi::Field::HasAndBelongsToMany::Edit.new(
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
    end

    class HasAndBelongsToManyIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::HasAndBelongsToMany.new(:categories)
        @book = Book.new(original_title: "The Hobbit")
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::HasAndBelongsToMany::Index.new(
          field: @field,
          record: @book,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Index, @component
      end
    end

    class HasAndBelongsToManyShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::HasAndBelongsToMany.new(:categories)
        @book = Book.new(original_title: "The Hobbit")
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::HasAndBelongsToMany::Show.new(
          field: @field,
          record: @book,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Show, @component
      end
    end
  end
end
