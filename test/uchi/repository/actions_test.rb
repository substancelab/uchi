# frozen_string_literal: true

require "test_helper"

# Test action for repository tests
class TestRepositoryAction < Uchi::Action
  def perform(records, input = {})
    Uchi::ActionResponse.success("Action executed")
  end
end

# Test repository with actions
class TestRepositoryWithActions < Uchi::Repository
  def self.model
    Author
  end

  def fields
    [Uchi::Field::String.new(:name)]
  end

  def actions
    [TestRepositoryAction.new]
  end
end

# Test repository with actions configured for specific contexts
class TestRepositoryWithScopedActions < Uchi::Repository
  def self.model
    Author
  end

  def fields
    [Uchi::Field::String.new(:name)]
  end

  def actions
    [
      TestRepositoryAction.new.on(:row),
      TestRepositoryAction.new.on(:show)
    ]
  end
end

class UchiRepositoryActionsTest < ActiveSupport::TestCase
  test "#actions returns empty array by default" do
    repository = Uchi::Repositories::Author.new

    assert_equal [], repository.actions
  end

  test "#actions can be overridden to return actions" do
    repository = TestRepositoryWithActions.new

    assert_equal 1, repository.actions.size
    assert_instance_of TestRepositoryAction, repository.actions.first
  end

  test "actions are instances of Uchi::Action" do
    repository = TestRepositoryWithActions.new

    repository.actions.each do |action|
      assert_kind_of Uchi::Action, action
    end
  end

  test "#actions_for returns only actions configured for the given context" do
    repository = TestRepositoryWithScopedActions.new

    assert_equal 1, repository.actions_for(:row).size
    assert_equal 1, repository.actions_for(:show).size
    assert_equal [:row], repository.actions_for(:row).first.on
    assert_equal [:show], repository.actions_for(:show).first.on
  end

  test "#index_actions returns a New action by default" do
    repository = Uchi::Repositories::Author.new

    assert_equal 1, repository.index_actions.size
    assert_instance_of Uchi::Action::New, repository.index_actions.first
  end
end
