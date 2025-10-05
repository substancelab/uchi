require "test_helper"
require "ostruct"

module Uchi
  class Field
    class BlankTest < ActiveSupport::TestCase
      def setup
        @field = Uchi::Field::Blank.new(:separator)
        @form = OpenStruct.new(object: OpenStruct.new(separator: nil))
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

      test "#edit_component returns an instance of Edit component" do
        component = @field.edit_component(form: @form, hint: "Custom hint", label: "Custom label", repository: @repository)
        assert_equal "Custom hint", component.hint
        assert_equal "Custom label", component.label
        assert_equal @field, component.field
        assert_equal @form, component.form
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Blank::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Blank::Index, component
      end

      test "#searchable? returns false when explicitly set" do
        field = Uchi::Field::Blank.new(:separator, searchable: false)
        assert_not field.searchable?
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Blank::Show, component
      end

      test "#sortable? returns false when explicitly set" do
        field = Uchi::Field::Blank.new(:separator, sortable: false)
        assert_not field.sortable?
      end
    end
  end
end
