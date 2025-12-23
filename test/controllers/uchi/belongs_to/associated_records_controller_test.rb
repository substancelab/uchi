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

      test "GET index uses the title method for the label text" do
        get uchi.belongs_to_associated_records_path(
          field: "book",
          model: "Title",
          record_id: @title.id
        )

        # Check that list items have id attributes (format: Title-book_book_{id})
        assert_select "li[id*='_book_#{@book1.id}']", text: @book1.original_title
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

      test "GET index respects custom collection_query lambda for filtering" do
        # Create additional books - some active, some inactive (using title as a proxy)
        active_book1 = Book.create!(original_title: "Active: The Hobbit")
        active_book2 = Book.create!(original_title: "Active: The Silmarillion")
        inactive_book = Book.create!(original_title: "Inactive: Old Book")

        # Stub the repository's fields method to use a custom collection_query
        Uchi::Repositories::Title.class_eval do
          alias_method :original_fields, :fields

          def fields
            [
              Uchi::Field::BelongsTo.new(:book).collection_query(->(query) {
                query.where("original_title LIKE ?", "Active:%")
              }),
              Uchi::Field::String.new(:locale),
              Uchi::Field::String.new(:title)
            ]
          end
        end

        begin
          get uchi.belongs_to_associated_records_path(
            field: "book",
            model: "Title",
            record_id: @title.id
          )

          assert_response :success

          # Should include only active books
          assert_select "li[data-id='#{active_book1.id}']"
          assert_select "li[data-id='#{active_book2.id}']"

          # Should NOT include inactive book
          assert_select "li[data-id='#{inactive_book.id}']", count: 0

          # Should not include the original books from setup (not matching filter)
          assert_select "li[data-id='#{@book1.id}']", count: 0
          assert_select "li[data-id='#{@book2.id}']", count: 0
        ensure
          # Restore original method
          Uchi::Repositories::Title.class_eval do
            alias_method :fields, :original_fields
            remove_method :original_fields
          end
        end
      end

      test "GET index applies collection_query with ordering" do
        # Create books that should be ordered
        book_z = Book.create!(original_title: "Z Book")
        book_a = Book.create!(original_title: "A Book")
        book_m = Book.create!(original_title: "M Book")

        # Stub the repository's fields method to use ordering in collection_query
        Uchi::Repositories::Title.class_eval do
          alias_method :original_fields, :fields

          def fields
            [
              Uchi::Field::BelongsTo.new(:book).collection_query(->(query) {
                query.order(original_title: :desc)
              }),
              Uchi::Field::String.new(:locale),
              Uchi::Field::String.new(:title)
            ]
          end
        end

        begin
          get uchi.belongs_to_associated_records_path(
            field: "book",
            model: "Title",
            record_id: @title.id
          )

          assert_response :success

          # Parse the response to check order
          html = Nokogiri::HTML(response.body)
          book_ids = html.css("li[data-id]").map { |li| li["data-id"].to_i }

          # Find positions of our test books
          z_position = book_ids.index(book_z.id)
          a_position = book_ids.index(book_a.id)
          m_position = book_ids.index(book_m.id)

          # Verify descending order (Z should come before M, M before A)
          assert z_position < m_position, "Z Book should come before M Book"
          assert m_position < a_position, "M Book should come before A Book"
        ensure
          # Restore original method
          Uchi::Repositories::Title.class_eval do
            alias_method :fields, :original_fields
            remove_method :original_fields
          end
        end
      end
    end
  end
end
