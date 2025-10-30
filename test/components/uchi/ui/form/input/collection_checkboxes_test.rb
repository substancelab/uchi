require "test_helper"

module Uchi
  module Ui
    module Form
      module Input
        class CollectionCheckboxesTest < ViewComponent::TestCase
          class Tag
            attr_accessor :id, :name

            def initialize(id, name)
              @id = id
              @name = name
            end
          end

          def setup
            @tags = [
              Tag.new(1, "Ruby"),
              Tag.new(2, "Rails"),
              Tag.new(3, "JavaScript")
            ]

            @record = Author.new(name: "Test Author")
            @record.define_singleton_method(:tag_ids) { [1, 3] }
            @record.define_singleton_method(:tag_ids=) { |val| @tag_ids = val }

            @view_context = ActionController::Base.new.view_context
            @form = ActionView::Helpers::FormBuilder.new(:author, @record, @view_context, {})

            @component = Uchi::Ui::Form::Input::CollectionCheckboxes.new(
              attribute: :tag_ids,
              collection: @tags,
              form: @form,
              label: "Select Tags",
              hint: "Choose one or more tags",
              value_method: :id,
              text_method: :name
            )
          end

          test "renders collection checkboxes" do
            render_inline(@component)

            assert_selector("input[type='hidden'][name='author[tag_ids][]']", visible: :all, count: 1)
            assert_selector("input[type='checkbox'][name='author[tag_ids][]']", count: 3)
          end

          test "renders label when provided" do
            render_inline(@component)

            assert_selector("label", text: "Select Tags")
          end

          test "does not render label when not provided" do
            component = Uchi::Ui::Form::Input::CollectionCheckboxes.new(
              attribute: :tag_ids,
              collection: @tags,
              form: @form
            )
            render_inline(component)

            assert_no_selector("label", text: "Select Tags")
          end

          test "renders hint when provided" do
            render_inline(@component)

            assert_selector("p", text: "Choose one or more tags")
          end

          test "does not render hint when not provided" do
            component = Uchi::Ui::Form::Input::CollectionCheckboxes.new(
              attribute: :tag_ids,
              collection: @tags,
              form: @form
            )
            render_inline(component)

            assert_no_selector("p", text: "Choose one or more tags")
          end

          test "renders checkbox labels for each item" do
            render_inline(@component)

            assert_selector("label", text: "Ruby")
            assert_selector("label", text: "Rails")
            assert_selector("label", text: "JavaScript")
          end

          test "renders checkboxes with correct values" do
            render_inline(@component)

            assert_selector("input[type='checkbox'][value='1']")
            assert_selector("input[type='checkbox'][value='2']")
            assert_selector("input[type='checkbox'][value='3']")
          end

          test "applies disabled state to all checkboxes" do
            component = Uchi::Ui::Form::Input::CollectionCheckboxes.new(
              attribute: :tag_ids,
              collection: @tags,
              form: @form,
              disabled: true
            )
            render_inline(component)

            assert_selector("input[type='checkbox'][disabled]", count: 3)
          end

          test "renders errors when present" do
            @record.errors.add(:tag_ids, "must be selected")
            render_inline(@component)

            assert_selector("p", text: /MUST BE SELECTED/i)
          end

          test "applies error styling when errors present" do
            @record.errors.add(:tag_ids, "must be selected")
            component = Uchi::Ui::Form::Input::CollectionCheckboxes.new(
              attribute: :tag_ids,
              collection: @tags,
              form: @form
            )

            render_inline(component)

            # Check that error classes are applied to checkboxes
            assert component.errors?
          end

          test "uses custom value and text methods" do
            custom_tags = [
              OpenStruct.new(identifier: "ruby", title: "Ruby Programming"),
              OpenStruct.new(identifier: "rails", title: "Rails Framework")
            ]

            component = Uchi::Ui::Form::Input::CollectionCheckboxes.new(
              attribute: :tag_ids,
              collection: custom_tags,
              form: @form,
              value_method: :identifier,
              text_method: :title
            )

            render_inline(component)

            assert_selector("input[type='checkbox'][value='ruby']")
            assert_selector("input[type='checkbox'][value='rails']")
            assert_selector("label", text: "Ruby Programming")
            assert_selector("label", text: "Rails Framework")
          end

          test "handles empty collection" do
            component = Uchi::Ui::Form::Input::CollectionCheckboxes.new(
              attribute: :tag_ids,
              collection: [],
              form: @form
            )

            render_inline(component)

            # Should only have the hidden field, no checkboxes
            assert_selector("input[type='hidden'][name='author[tag_ids][]']", visible: :all, count: 1)
            assert_selector("input[type='checkbox']", count: 0)
          end
        end
      end
    end
  end
end
