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

class ErrorAuthorAction < Uchi::Action
  def perform(records, input = {})
    Uchi::ActionResponse.error("Something went wrong with #{records.size} authors")
  end
end

class DownloadAuthorAction < Uchi::Action
  def perform(records, input = {})
    # Create a temporary file for testing
    file = Tempfile.new(["authors", ".csv"])
    file.write("Name\n")
    records.each { |r| file.write("#{r.name}\n") }
    file.close

    Uchi::ActionResponse.success("Downloaded")
      .download(file_path: file.path, filename: "authors.csv")
  end
end

class TurboStreamAuthorAction < Uchi::Action
  def perform(records, input = {})
    Uchi::ActionResponse.success("Turbo stream response")
      .turbo_stream { "replace" }
  end
end

class FailingAuthorAction < Uchi::Action
  def perform(records, input = {})
    raise StandardError, "Action failed unexpectedly"
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
      RedirectAuthorAction.new,
      ErrorAuthorAction.new,
      DownloadAuthorAction.new,
      TurboStreamAuthorAction.new,
      FailingAuthorAction.new
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

      test "POST create handles error response with alert flash" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "ErrorAuthorAction",
            id: @alice.id
          }

        assert_response :redirect
        assert_equal "Something went wrong with 1 authors", flash[:alert]
        assert_nil flash[:success]
      end

      test "POST create handles error response for multiple records" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "ErrorAuthorAction",
            ids: [@alice.id, @bob.id]
          }

        assert_response :redirect
        assert_equal "Something went wrong with 2 authors", flash[:alert]
      end

      test "POST create handles download response" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "DownloadAuthorAction",
            id: @alice.id
          }

        assert_response :success
        assert_equal "text/csv", response.content_type
        assert_match(/filename="authors.csv"/, response.headers["Content-Disposition"])
        assert_includes response.body, "Alice"
      end

      test "POST create handles turbo_stream response" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "TurboStreamAuthorAction",
            id: @alice.id
          }

        assert_response :success
        assert_equal "replace", response.body
      end

      test "POST create raises error when action raises exception" do
        assert_raises(StandardError) do
          post "/uchi/actions/executions",
            params: {
              model: "Author",
              action_name: "FailingAuthorAction",
              id: @alice.id
            }
        end
      end

      test "POST create handles invalid record ID gracefully" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "PublishAuthorAction",
            id: 999999
          }

        assert_response :redirect
        # Action runs with no records found
        assert_equal "Published 0 authors", flash[:success]
      end

      test "POST create processes only valid record IDs in batch" do
        post "/uchi/actions/executions",
          params: {
            model: "Author",
            action_name: "PublishAuthorAction",
            ids: [@alice.id, 999999]
          }

        assert_response :redirect
        # Only processes the valid record
        assert_equal "Published 1 authors", flash[:success]
        assert_equal "Published: Alice", @alice.reload.name
      end
    end
  end
end
