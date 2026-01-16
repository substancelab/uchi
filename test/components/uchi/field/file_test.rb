# frozen_string_literal: true

require "test_helper"
require "ostruct"

module Uchi
  class Field
    class FileTest < ActiveSupport::TestCase
      def setup
        @book = Book.new(sample: nil)
        @field = Uchi::Field::File.new(:sample)
        @form = OpenStruct.new(object: @book)
        @repository = Uchi::Repositories::Book.new
      end

      test "inherits from Uchi::Field" do
        assert_kind_of Uchi::Field, @field
      end

      test "has default options" do
        assert_equal [:edit, :index, :new, :show], @field.on
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
        assert_kind_of Uchi::Field::File::Edit, component
      end

      test "#index_component returns an instance of Index component" do
        component = @field.index_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::File::Index, component
      end

      test "#searchable? returns false by default" do
        assert_not @field.searchable?
      end

      test "#show_component returns an instance of Show component" do
        component = @field.show_component(record: @form.object, repository: @repository)
        assert_equal @field, component.field
        assert_equal @form.object, component.record
        assert_equal @repository, component.repository
        assert_kind_of Uchi::Field::File::Show, component
      end

      test "#sortable? returns false by default" do
        assert_not @field.sortable?
      end
    end

    class FileEditTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::File.new(:sample)
        @record = Book.new(sample: nil)
        @repository = Uchi::Repositories::Book.new
        @view_context = ActionController::Base.new.view_context

        @form = ActionView::Helpers::FormBuilder.new(:book, @record, @view_context, {})

        @component = Uchi::Field::File::Edit.new(
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

      test "renders a file input field" do
        render_inline(@component)

        assert_selector("input[type='file'][name='book[sample]']")
      end

      test "renders label with specified text" do
        render_inline(@component)

        assert_selector("label[for='book_sample']", text: "Custom label")
      end

      test "renders hint when provided" do
        render_inline(@component)

        assert_selector("p[id=book_sample_hint]", text: "Custom hint")
      end

      test "initializes the input component with the correct options" do
        expected_options = {
          attribute: :sample,
          form: @form,
          label: {content: "Custom label"},
          hint: {content: "Custom hint"}
        }
        assert_equal expected_options, @component.send(:options)
      end
    end

    class FileIndexTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::File.new(:sample)
        @record = Book.new
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::File::Index.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Index, @component
      end

      test "renders placeholder when no file is attached" do
        result = render_inline(@component)

        assert_includes result.to_html, "—"
      end

      test "renders filename when file is attached" do
        # Create a record with an attached file
        file = ::File.open(Rails.root.join("test/fixtures/files/pdf.pdf"))
        @record = Book.new(sample: file)

        @component = Uchi::Field::File::Index.new(
          field: @field,
          record: @record,
          repository: @repository
        )

        result = render_inline(@component)

        assert_includes result.to_html, "pdf.pdf"
      end
    end

    class FileShowTest < ViewComponent::TestCase
      def setup
        @field = Uchi::Field::File.new(:sample)
        file = ::File.open(Rails.root.join("test/fixtures/files/pdf.pdf"))
        @record = Book.create!(sample: file)
        @repository = Uchi::Repositories::Book.new

        @component = Uchi::Field::File::Show.new(
          field: @field,
          record: @record,
          repository: @repository
        )
      end

      test "inherits from Base component" do
        assert_kind_of Uchi::Field::Base::Show, @component
      end

      test "renders a dash when no file is attached" do
        @record.sample.detach

        result = render_inline(@component)

        assert_includes result.to_html, "—"
      end

      test "renders download link when file is attached" do
        result = render_inline(@component)

        assert_includes result.to_html, "pdf.pdf"
      end
    end
  end
end
