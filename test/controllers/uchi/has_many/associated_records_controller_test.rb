require "test_helper"

module Uchi
  module HasMany
    class AssociatedRecordsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @book = Book.create!(original_title: "The Hobbit")
        @title1 = Title.create!(title: "El Hobbit", locale: "es", book: @book)
        @title2 = Title.create!(title: "Hobbitten", locale: "da", book: @book)
      end

      test "GET index responds successfully" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_response :success
      end

      test "GET index renders a ul element" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_select "ul"
      end

      test "GET index renders associated records as list items" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_select "ul li[role='option']", count: 2
      end

      test "GET index renders each associated record with correct data-id attribute" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_select "li[data-id='#{@title1.id}']"
        assert_select "li[data-id='#{@title2.id}']"
      end

      test "GET index renders each associated record with correct data-action attribute" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_select "input[data-action='change->has-many#handleCheckboxChange']", count: 2
      end

      test "GET index renders each associated record with id attribute" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        # Check that list items have id attributes (format: Book-titles_title_{id})
        assert_select "li[id*='_title_#{@title1.id}']"
        assert_select "li[id*='_title_#{@title2.id}']"
      end

      test "GET index uses the title method for the label text" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_select "label[for*='checkbox_title_#{@title1.id}']", text: @title1.title
      end

      test "GET index assigns @current_values to the current associated record" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_equal [@title1, @title2], assigns(:current_values)
      end

      test "GET index assigns @field_name to the field parameter" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: @book.id
        )

        assert_equal "titles", assigns(:field_name)
      end

      test "GET index filters records by query parameter" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          query: "el hobb",
          record_id: @book.id
        )

        assert_response :success
        assert_select "li[data-id='#{@title1.id}']"
        assert_select "li[data-id='#{@title2.id}']", count: 0
      end

      test "GET index raises error when field does not exist" do
        assert_raises NameError do
          get uchi.has_many_associated_records_path(
            field: "nonexistent_field",
            model: "Book",
            record_id: @book.id
          )
        end
      end

      test "GET index raises error when association does not exist on model" do
        assert_raises NameError do
          get uchi.has_many_associated_records_path(
            field: "invalid_association",
            model: "Book",
            record_id: @book.id
          )
        end
      end

      test "GET index raises error when model has no repository" do
        assert_raises NameError do
          get uchi.has_many_associated_records_path(
            field: "titles",
            model: "NonexistentModel",
            record_id: @book.id
          )
        end
      end

      test "GET index returns not found when record does not exist" do
        get uchi.has_many_associated_records_path(
          field: "titles",
          model: "Book",
          record_id: 99999
        )

        assert_response :not_found
      end

      test "GET index respects custom collection_query lambda for filtering" do
        title_fr = Title.create!(title: "Le Hobbit", locale: "fr", book: @book)
        title_uk = Title.create!(title: "The Hobbit", locale: "en-UK", book: @book)
        title_us = Title.create!(title: "The Hobbit", locale: "en-US", book: @book)

        # Stub the repository's fields method to use a custom collection_query
        Uchi::Repositories::Book.class_eval do
          alias_method :original_fields, :fields

          def fields
            [
              Uchi::Field::HasMany.new(:titles).collection_query(->(query) {
                query.where("locale LIKE ?", "en-%")
              })
            ]
          end
        end

        begin
          get uchi.has_many_associated_records_path(
            field: "titles",
            model: "Book",
            record_id: @book.id
          )

          assert_response :success

          # Should include only english titles
          assert_select "li[data-id='#{title_uk.id}']"
          assert_select "li[data-id='#{title_us.id}']"

          # Should NOT include french title
          assert_select "li[data-id='#{title_fr.id}']", count: 0

          # Should not include the original titles from setup (not matching filter)
          assert_select "li[data-id='#{@title1.id}']", count: 0
        ensure
          # Restore original method
          Uchi::Repositories::Book.class_eval do
            alias_method :fields, :original_fields
            remove_method :original_fields
          end
        end
      end

      test "GET index applies collection_query with ordering" do
        # Create books that should be ordered
        title_z = Title.create!(title: "Z Title", book: @book)
        title_a = Title.create!(title: "A Title", book: @book)
        title_m = Title.create!(title: "M Title", book: @book)

        # Stub the repository's fields method to use ordering in collection_query
        Uchi::Repositories::Book.class_eval do
          alias_method :original_fields, :fields

          def fields
            [
              Uchi::Field::HasMany.new(:titles).collection_query(->(query) {
                query.order(title: :desc)
              })
            ]
          end
        end

        begin
          get uchi.has_many_associated_records_path(
            field: "titles",
            model: "Book",
            record_id: @book.id
          )

          assert_response :success

          # Parse the response to check order
          html = Nokogiri::HTML(response.body)
          title_ids = html.css("li[data-id]").map { |li| li["data-id"].to_i }

          # Find positions of our test titles
          z_position = title_ids.index(title_z.id)
          a_position = title_ids.index(title_a.id)
          m_position = title_ids.index(title_m.id)

          # Verify descending order (Z should come before M, M before A)
          assert z_position < m_position, "Z Title should come before M Title"
          assert m_position < a_position, "M Title should come before A Title"
        ensure
          # Restore original method
          Uchi::Repositories::Book.class_eval do
            alias_method :fields, :original_fields
            remove_method :original_fields
          end
        end
      end
    end
  end
end
