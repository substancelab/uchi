require "test_helper"
require "ostruct"

module Uchi
  class Field
    class HasManyTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::HasMany.new(:books)
        @form = OpenStruct.new(object: Author.new)
        @repository = Uchi::Repositories::Author.new
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options specific to HasMany field" do
        assert_equal [:show], @field.on  # Different from other fields - only on show
        assert_not @field.searchable?
        assert @field.sortable?
      end

      test "has custom collection_query" do
        custom_query = ->(query) { query.where(published: true) }
        field = Uchi::Field::HasMany.new(:books, collection_query: custom_query)
        assert_equal custom_query, field.collection_query
      end

      test "uses default collection_query" do
        assert_equal Uchi::Field::HasMany::DEFAULT_COLLECTION_QUERY, @field.collection_query
      end

      test "#param_key returns foreign key name" do
        assert_equal :books_id, @field.param_key
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
        assert_kind_of Uchi::Field::HasMany::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::HasMany::Index, component
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::HasMany::Show, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::HasMany.new(:books, searchable: false)
        assert_not field.searchable?
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::HasMany.new(:books, sortable: false)
        assert_not field.sortable?
      end
    end

    class HasManyEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::HasMany.new(:books)
        @author = Author.new(name: "J.R.R. Tolkien")
        @repository = Uchi::Repositories::Author.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:author, @author, @view_context, {})

        @component = Uchi::Field::HasMany::Edit.new(
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

    class HasManyIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::HasMany.new(:books)
        @author = Author.new(name: "J.R.R. Tolkien")
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::HasMany::Index.new(
          field: @field,
          record: @author,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Index, @component
      end
    end

    class HasManyShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::HasMany.new(:books)
        @author = Author.new(name: "J.R.R. Tolkien")
        @repository = Uchi::Repositories::Author.new

        @component = Uchi::Field::HasMany::Show.new(
          field: @field,
          record: @author,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Show, @component
      end
    end
  end
end
