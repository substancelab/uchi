require "test_helper"
require "ostruct"

module Uchi
  class Field
    class IdTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::Id.new(:id)
        @form = OpenStruct.new(object: OpenStruct.new(id: 123))
        @repository = Uchi::Repositories::Author.new
      end

      test "inherits from Uchi::Field::Number" do
        assert_kind_of Uchi::Field::Number, @field
        assert_kind_of Uchi::Field, @field
      end

      test "has default options specific to Id field" do
        assert_equal [:index, :show], @field.on  # Different from other fields
        assert @field.searchable?  # Different from other fields
        assert @field.sortable?
      end

      test "does not have edit_component because not in :edit on list" do
        # Since Id field defaults to [:index, :show], it doesn't include :edit
        # But we can still create the component if needed
        assert_nothing_raised do
          @field.edit_component(form: @form, hint: "Custom hint", label: "Custom label", repository: @repository)
        end
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Id::Index, component
      end

      test "#searchable? returns true by default for Id field" do
        assert @field.searchable?
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::Id.new(:id, searchable: false)
        assert_not field.searchable?
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Id::Show, component
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::Id.new(:id, sortable: false)
        assert_not field.sortable?
      end
    end
  end
end
