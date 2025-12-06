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

class TestActionWithIcon < Uchi::Action
  def icon
    "check-circle"
  end

  def perform(records, input = {})
    Uchi::ActionResponse.success("Done")
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

  test "#icon returns nil by default" do
    action = TestPublishAction.new

    assert_nil action.icon
  end

  test "#icon can be overridden" do
    action = TestActionWithIcon.new

    assert_equal "check-circle", action.icon
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
end
