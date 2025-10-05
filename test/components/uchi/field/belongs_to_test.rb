require "test_helper"
require "ostruct"

module Uchi
  class Field
    class BelongsToTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::BelongsTo.new(:author)
        @form = OpenStruct.new(object: Author.new)
        @repository = Uchi::Repositories::Author.new
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options" do
        assert_equal [:edit, :index, :show], @field.on
        assert_not @field.searchable?
        assert @field.sortable?
      end

      test "has custom collection_query" do
        custom_query = ->(query) { query.where(active: true) }
        field = Uchi::Field::BelongsTo.new(:author, collection_query: custom_query)
        assert_equal custom_query, field.collection_query
      end

      test "uses default collection_query" do
        assert_equal Uchi::Field::BelongsTo::DEFAULT_COLLECTION_QUERY, @field.collection_query
      end

      test "#param_key returns foreign key name" do
        assert_equal :author_id, @field.param_key
      end

      test "#group_as returns :attributes" do
        assert_equal :attributes, @field.group_as(:edit)
        assert_equal :attributes, @field.group_as(:show)
      end

      test "#edit_component returns an instance of Edit component" do
        component = @field.edit_component(form: @form, hint: "Custom hint", label: "Custom label", repository: @repository)
        assert_equal "Custom hint", component.hint
        assert_equal "Custom label", component.label
        assert_equal @field, component.field
        assert_equal @form, component.form
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::BelongsTo::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::BelongsTo::Index, component
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::BelongsTo::Show, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::BelongsTo.new(:author, searchable: false)
        assert_not field.searchable?
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::BelongsTo.new(:author, sortable: false)
        assert_not field.sortable?
      end
    end
  end
end
