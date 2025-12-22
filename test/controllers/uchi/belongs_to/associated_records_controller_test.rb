require "test_helper"

module Uchi
  module BelongsTo
    class AssociatedRecordsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @book1 = Book.create!(original_title: "The Hobbit")
        @book2 = Book.create!(original_title: "The Lord of the Rings")
        @title = Title.create!(title: "El Hobbit", locale: "es", book: @book1)
      end

      test "GET index responds successfully" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        assert_response :success
      end

      test "GET index renders a ul element" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        assert_select "ul"
      end

      test "GET index renders associated records as list items" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        assert_select "ul li[role='option']", count: 2
      end

      test "GET index renders each associated record with correct data-id attribute" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        assert_select "li[data-id='#{@book1.id}']"
        assert_select "li[data-id='#{@book2.id}']"
      end

      test "GET index renders each associated record with correct data-action attribute" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        assert_select "li[data-action='belongs-to#selectOption']", count: 2
      end

      test "GET index renders each associated record with id attribute" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        # Check that list items have id attributes (format: Title-book_book_{id})
        assert_select "li[id*='_book_#{@book1.id}']"
        assert_select "li[id*='_book_#{@book2.id}']"
      end

      test "GET index assigns @current_value to the current associated record" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        assert_equal @book1, assigns(:current_value)
      end

      test "GET index assigns @field_name to the field parameter" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        assert_equal "book", assigns(:field_name)
      end

      test "GET index filters records by query parameter" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          query: "Hobbit",
          record_id: @title.id
        )

        assert_response :success
        assert_select "li[data-id='#{@book1.id}']"
        assert_select "li[data-id='#{@book2.id}']", count: 0
      end

      test "GET index raises error when field does not exist" do
        assert_raises NameError do
          get uchi.belongs_to_associated_records_path(
            field: "nonexistent_field",
            model: "Title",
            record_id: @title.id
          )
        end
      end

      test "GET index raises error when association does not exist on model" do
        assert_raises NameError do
          get uchi.belongs_to_associated_records_path(
            field: "invalid_association",
            model: "Title",
            record_id: @title.id
          )
        end
      end

      test "GET index raises error when model has no repository" do
        assert_raises NameError do
          get uchi.belongs_to_associated_records_path(
            field: "book",
            model: "NonexistentModel",
            record_id: @title.id
          )
        end
      end

      test "GET index returns not found when record does not exist" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: 99999
        )

        assert_response :not_found
      end
    end
  end
end
