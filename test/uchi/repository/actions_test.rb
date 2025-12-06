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
end
