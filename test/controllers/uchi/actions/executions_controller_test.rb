# frozen_string_literal: true

require "test_helper"

# Test action for controller tests
class PublishAuthorAction < Uchi::Action
  def perform(records, input = {})
    records.each { |r| r.update!(name: "Published: #{r.name}") }
    Uchi::ActionResponse.success("Published #{records.size} authors")
  end
end

class ExportAuthorAction < Uchi::Action
  def fields
    [Uchi::Field::String.new(:format)]
  end

  def perform(records, input = {})
    format = input[:format] || "csv"
    Uchi::ActionResponse.success("Exported #{records.size} authors as #{format}")
  end
end

class RedirectAuthorAction < Uchi::Action
  def perform(records, input = {})
    Uchi::ActionResponse.success("Redirected").redirect_to(path: "/uchi/authors")
  end
end

# Test repository with actions (not in Uchi::Repositories to avoid auto-discovery)
class AuthorWithActionsRepository < Uchi::Repository
  def self.model
    Author
  end

  def fields
    [Uchi::Field::String.new(:name)]
  end

  def actions
    [
      PublishAuthorAction.new,
      ExportAuthorAction.new,
      RedirectAuthorAction.new
    ]
  end
end

module Uchi
  module Actions
    class ExecutionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @alice = Author.create!(name: "Alice")
        @bob = Author.create!(name: "Bob")

        # Temporarily remove standard Author repository and inject test repository
        if Uchi::Repositories.const_defined?(:Author)
          @original_author_repository = Uchi::Repositories::Author
          Uchi::Repositories.send(:remove_const, :Author)
        end
        Uchi::Repositories.const_set(:Author, AuthorWithActionsRepository)
      end

      teardown do
        # Restore original Author repository
        Uchi::Repositories.send(:remove_const, :Author) if Uchi::Repositories.const_defined?(:Author)
        if @original_author_repository
          Uchi::Repositories.const_set(:Author, @original_author_repository)
        end
      end

      test "POST create runs action on single record" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "PublishAuthorAction",
            id: @alice.id
          }

        assert_response :redirect
        assert_equal "Published: Alice", @alice.reload.name
        assert_equal "Published 1 authors", flash[:success]
      end

      test "POST create runs action on multiple records" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "PublishAuthorAction",
            ids: [@alice.id, @bob.id]
          }

        assert_response :redirect
        assert_equal "Published: Alice", @alice.reload.name
        assert_equal "Published: Bob", @bob.reload.name
        assert_equal "Published 2 authors", flash[:success]
      end

      test "POST create passes input to action" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "ExportAuthorAction",
            id: @alice.id,
            format: "json"
          }

        assert_response :redirect
        assert_includes flash[:success], "json"
      end

      test "POST create redirects to repository index by default" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "PublishAuthorAction",
            id: @alice.id
          }

        # The repository's model is Author, so it redirects to /uchi/authors
        assert_redirected_to "/uchi/authors"
      end

      test "POST create redirects to custom path if specified in response" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "RedirectAuthorAction",
            id: @alice.id
          }

        assert_redirected_to "/uchi/authors"
      end

      test "POST create raises error for non-existent model" do
        assert_raises(NameError) do
          post "/uchi/actions/executions",
            params: {
              model: "NonExistent",
              action_name: "PublishAuthorAction",
              id: @alice.id
            }
        end
      end

      test "POST create raises error for non-existent action" do
        assert_raises(NameError) do
          post "/uchi/actions/executions",
            params: {
              model: "Author",
              action_name: "non_existent_action",
              id: @alice.id
            }
        end
      end
    end
  end
end
