# frozen_string_literal: true

require "test_helper"
require "ostruct"

module Uchi
  class Field
    class ImageTest < ActiveSupport::TestCase
      def setup
        @book = Book.new(cover: nil)
        @field = Uchi::Field::Image.new(:cover)
        @form = OpenStruct.new(object: @book)
        @repository = Uchi::Repositories::Book.new
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options" do
        assert_equal [:edit, :index, :show], @field.on
        assert_not @field.searchable?
        assert_not @field.sortable?
      end

      test "#edit_component returns an instance of Edit component" do
        component = @field.edit_component(form: @form, hint: "Custom hint", label: "Custom label", repository: @repository)
        assert_equal "Custom hint", component.hint
        assert_equal "Custom label", component.label
        assert_equal @field, component.field
        assert_equal @form, component.form
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Image::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Image::Index, component
      end

      test "#searchable? returns false by default" do
        assert_not @field.searchable?
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::Image::Show, component
      end

      test "#sortable? returns false by default" do
        assert_not @field.sortable?
      end
    end

    class ImageEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Image.new(:cover)
        @record = Book.new(cover: nil)
        @repository = Uchi::Repositories::Book.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:book, @record, @view_context, {})

        @component = Uchi::Field::Image::Edit.new(
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

      test "renders a file input field with image accept attribute" do
        render_inline(@component)

        assert_selector("input[type='file'][name='book[cover]'][accept='image/*']")
      end

      test "renders label with specified text" do
        render_inline(@component)

        assert_selector("label[for='book_cover']", text: "Custom label")
      end

      test "renders hint when provided" do
        render_inline(@component)

        assert_selector("p[id=book_cover_hint]", text: "Custom hint")
      end

      test "initializes the input component with the correct options" do
        expected_options = {
          attribute: :cover,
          form: @form,
          label: {content: "Custom label"},
          hint: {content: "Custom hint"},
          input: {options: {accept: "image/*"}}
        }
        assert_equal expected_options, @component.send(:options)
      end
    end

    class ImageIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Image.new(:cover)
        @record = Book.new
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::Image::Index.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Index, @component
      end

      test "renders placeholder when no image is attached" do
        result = render_inline(@component)

        assert_includes result.to_html, "—"
      end

      test "renders thumbnail when image is attached" do
        # Create a record with an attached image
        image = ::File.open(Rails.root.join("test/fixtures/files/image.png"))
        @record = Book.create!(cover: image)

        @component = Uchi::Field::Image::Index.new(
          field: @field,
          record: @record,
          repository: @repository
        )

        render_inline(@component)

        assert_selector("img")
        assert_selector("img.rounded")
      end
    end

    class ImageShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::Image.new(:cover)
        image = ::File.open(Rails.root.join("test/fixtures/files/image.png"))
        @record = Book.create!(cover: image)
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::Image::Show.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Show, @component
      end

      test "renders placeholder when no image is attached" do
        @record.cover.detach

        result = render_inline(@component)

        assert_includes result.to_html, "—"
      end

      test "renders image when image is attached" do
        render_inline(@component)

        assert_selector("img")
        assert_selector("img.rounded-lg")
      end
    end
  end
end
