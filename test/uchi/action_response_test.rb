# frozen_string_literal: true

require "test_helper"

class UchiActionResponseTest < ActiveSupport::TestCase
  test ".success creates a success response" do
    response = Uchi::ActionResponse.success("Done")

    assert response.success?
    assert_equal false, response.error?
    assert_equal "Done", response.message_text
  end

  test ".success can be created without a message" do
    response = Uchi::ActionResponse.success

    assert response.success?
    assert_nil response.message_text
  end

  test ".error creates an error response" do
    response = Uchi::ActionResponse.error("Failed")

    assert response.error?
    assert_equal false, response.success?
    assert_equal "Failed", response.message_text
  end

  test ".error can be created without a message" do
    response = Uchi::ActionResponse.error

    assert response.error?
    assert_nil response.message_text
  end

  test "#message sets the message text" do
    response = Uchi::ActionResponse.success.message("Custom message")

    assert_equal "Custom message", response.message_text
  end

  test "#message returns self for chaining" do
    response = Uchi::ActionResponse.success

    result = response.message("Test")

    assert_equal response, result
  end

  test "#redirect_to sets the redirect path" do
    response = Uchi::ActionResponse.success.redirect_to(path: "/posts")

    assert_equal "/posts", response.redirect_path
    assert response.redirect?
  end

  test "#redirect_to returns self for chaining" do
    response = Uchi::ActionResponse.success

    result = response.redirect_to(path: "/posts")

    assert_equal response, result
  end

  test "#redirect? returns false by default" do
    response = Uchi::ActionResponse.success

    assert_equal false, response.redirect?
  end

  test "#download sets file path and filename" do
    response = Uchi::ActionResponse.success.download(
      file_path: "/tmp/export.csv",
      filename: "export.csv"
    )

    assert_equal "/tmp/export.csv", response.file_path
    assert_equal "export.csv", response.filename
    assert response.download?
  end

  test "#download returns self for chaining" do
    response = Uchi::ActionResponse.success

    result = response.download(file_path: "/tmp/test.csv", filename: "test.csv")

    assert_equal response, result
  end

  test "#download? returns false by default" do
    response = Uchi::ActionResponse.success

    assert_equal false, response.download?
  end

  test "#turbo_stream sets the turbo stream block" do
    block = proc { |stream| stream.replace "flash" }
    response = Uchi::ActionResponse.success.turbo_stream(&block)

    assert_equal block, response.turbo_stream_block
    assert response.turbo_stream?
  end

  test "#turbo_stream returns self for chaining" do
    response = Uchi::ActionResponse.success

    result = response.turbo_stream { |stream| stream.replace "flash" }

    assert_equal response, result
  end

  test "#turbo_stream? returns false by default" do
    response = Uchi::ActionResponse.success

    assert_equal false, response.turbo_stream?
  end

  test "chaining multiple methods" do
    response = Uchi::ActionResponse.success("Initial message")
      .message("Updated message")
      .redirect_to(path: "/posts/1")

    assert response.success?
    assert_equal "Updated message", response.message_text
    assert_equal "/posts/1", response.redirect_path
    assert response.redirect?
  end
end
