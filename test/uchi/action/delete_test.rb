# frozen_string_literal: true

require "test_helper"

class UchiActionDeleteTest < ActiveSupport::TestCase
  setup do
    @repository = Uchi::Repositories::Author.new
    @action = Uchi::Action::Delete.new
    @action.repository = @repository
  end

  test "#perform destroys the given records" do
    alice = Author.create!(name: "Alice")
    bob = Author.create!(name: "Bob")

    @action.perform([alice, bob])

    assert_not Author.exists?(alice.id)
    assert_not Author.exists?(bob.id)
  end

  test "#perform returns a success response with the repository's translated message" do
    alice = Author.create!(name: "Alice")

    response = @action.perform([alice])

    assert response.success?
    assert_equal @repository.translate.successful_destroy, response.message_text
  end

  test "#perform returns an error response with the repository's translated message when a record fails to destroy" do
    alice = Author.create!(name: "Alice")
    def alice.destroy
      false
    end

    response = @action.perform([alice])

    assert response.error?
    assert_equal @repository.translate.failed_destroy, response.message_text
  end

  test "#perform redirects back to the record's show page when a single record fails to destroy" do
    alice = Author.create!(name: "Alice")
    def alice.destroy
      false
    end

    response = @action.perform([alice])

    assert_equal @repository.routes.path_for(:show, id: alice.id), response.redirect_path
  end

  test "#perform does not set a redirect when multiple records fail to destroy" do
    alice = Author.create!(name: "Alice")
    bob = Author.create!(name: "Bob")
    [alice, bob].each do |author|
      def author.destroy
        false
      end
    end

    response = @action.perform([alice, bob])

    assert_nil response.redirect_path
  end
end
