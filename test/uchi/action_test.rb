# frozen_string_literal: true

require "test_helper"

# Test action for use in tests
class TestPublishAction < Uchi::Action
  def perform(records, input = {})
    records.each do |record|
      record.update!(name: "Published")
    end
    Uchi::ActionResponse.success("Published #{records.size} records")
  end
end

class TestActionWithFields < Uchi::Action
  def fields
    [
      Uchi::Field::String.new(:title),
      Uchi::Field::Boolean.new(:notify)
    ]
  end

  def perform(records, input = {})
    Uchi::ActionResponse.success("Processed with #{input[:title]}")
  end
end

class UchiActionTest < ActiveSupport::TestCase
  test "#name returns humanized class name by default" do
    action = TestPublishAction.new

    # Clear any existing translations first
    I18n.backend.reload!
    assert_equal "Test Publish Action", action.name
  end

  test "#name uses i18n translation if available" do
    I18n.backend.store_translations(:en, uchi: {action: {test_publish_action: {name: "Publish"}}})
    action = TestPublishAction.new

    assert_equal "Publish", action.name
  ensure
    # Clean up translation
    I18n.backend.reload!
  end

  test "#fields returns empty array by default" do
    action = TestPublishAction.new

    assert_equal [], action.fields
  end

  test "#fields can be overridden" do
    action = TestActionWithFields.new

    assert_equal 2, action.fields.size
    assert_equal :title, action.fields.first.name
  end

  test "#requires_input? returns false when no fields" do
    action = TestPublishAction.new

    assert_equal false, action.requires_input?
  end

  test "#requires_input? returns true when fields are present" do
    action = TestActionWithFields.new

    assert_equal true, action.requires_input?
  end

  test "#perform must be implemented by subclasses" do
    action = Uchi::Action.new

    error = assert_raises(NotImplementedError) do
      action.perform([])
    end

    assert_includes error.message, "Uchi::Action#perform must be implemented"
  end

  test "#perform receives records and input" do
    alice = Author.create!(name: "Alice")
    bob = Author.create!(name: "Bob")
    action = TestPublishAction.new

    response = action.perform([alice, bob], {})

    assert response.success?
    assert_equal "Published 2 records", response.message_text
    assert_equal "Published", alice.reload.name
    assert_equal "Published", bob.reload.name
  end

  test "#perform works with empty input" do
    alice = Author.create!(name: "Alice")
    action = TestActionWithFields.new

    response = action.perform([alice], {title: "Test"})

    assert response.success?
    assert_includes response.message_text, "Test"
  end

  test "#on returns [:show] by default" do
    action = TestPublishAction.new

    assert_equal [Uchi::View::SHOW], action.on
  end

  test "#on sets the contexts and returns self for chaining" do
    action = TestPublishAction.new

    result = action.on(:index)

    assert_same action, result
    assert_equal [Uchi::View::INDEX], action.on
  end

  test "#on flattens array arguments" do
    action = TestPublishAction.new

    action.on([Uchi::View::INDEX, Uchi::View::SHOW])

    assert_equal [Uchi::View::INDEX, Uchi::View::SHOW], action.on
  end

  test "#repository can be set and read" do
    action = TestPublishAction.new
    repository = Object.new

    action.repository = repository

    assert_same repository, action.repository
  end

  test "#render uses the repository set on the action" do
    action = TestPublishAction.new
    action.repository = fake_repository

    action.render(record: nil, view: fake_action_view)

    assert_equal Author, action.repository.model
  end

  test "#button_render uses the repository set on the action" do
    action = TestPublishAction.new
    action.repository = fake_repository

    action.button_render(record: Author.new, view: fake_action_view)

    assert_equal Author, action.repository.model
  end

  test "Edit is visible on :show by default" do
    assert_equal [Uchi::View::SHOW], Uchi::Action::Edit.new.on
  end

  test "Delete is only visible on :edit by default" do
    assert_equal [Uchi::View::EDIT], Uchi::Action::Delete.new.on
  end

  private

  # A minimal stand-in for the Uchi::Repository instance passed to
  # Action#render and Action#button_render.
  def fake_repository
    Struct.new(:model).new(Author)
  end

  # A minimal stand-in for the ActionView::Base instance passed to
  # Action#render and Action#button_render, just enough to exercise those
  # methods without a real view context.
  def fake_action_view
    Class.new do
      def uchi
        Struct.new(:actions_executions_path).new("/uchi/actions/executions")
      end

      def form_with(**)
        yield
      end

      def hidden_field_tag(*)
        ""
      end

      def button_tag(*, **)
        block_given? ? yield : ""
      end

      def safe_join(array)
        array.join
      end
    end.new
  end
end
