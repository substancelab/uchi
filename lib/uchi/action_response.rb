# frozen_string_literal: true

module Uchi
  # Represents the response from executing an action.
  #
  # ActionResponse uses a builder pattern for fluent chaining:
  #
  #   ActionResponse.success("Done").redirect_to(path: "/posts")
  #   ActionResponse.error("Failed").message("Try again later")
  #   ActionResponse.success("Exported").download(file_path: path, filename: "data.csv")
  class ActionResponse
    attr_reader :status, :message_text, :redirect_path, :file_path, :filename, :turbo_stream_block

    # Creates a successful response with an optional message.
    #
    # @param message [String, nil] - Success message to display
    # @return [ActionResponse]
    def self.success(message = nil)
      new(status: :success, message: message)
    end

    # Creates an error response with an optional message.
    #
    # @param message [String, nil] - Error message to display
    # @return [ActionResponse]
    def self.error(message = nil)
      new(status: :error, message: message)
    end

    def initialize(status:, message: nil)
      @status = status
      @message_text = message
    end

    # Sets the message to display.
    #
    # @param text [String] - The message text
    # @return [ActionResponse] self for chaining
    def message(text)
      @message_text = text
      self
    end

    # Sets a redirect path.
    #
    # @param path [String] - The path to redirect to
    # @return [ActionResponse] self for chaining
    def redirect_to(path:)
      @redirect_path = path
      self
    end

    # Sets a file to download.
    #
    # @param file_path [String] - Path to the file
    # @param filename [String] - Name for the downloaded file
    # @return [ActionResponse] self for chaining
    def download(file_path:, filename:)
      @file_path = file_path
      @filename = filename
      self
    end

    # Sets a custom Turbo Stream response.
    #
    # @yield [stream] Provides a Turbo Stream builder
    # @return [ActionResponse] self for chaining
    def turbo_stream(&block)
      @turbo_stream_block = block
      self
    end

    # Returns true if this is a success response.
    #
    # @return [Boolean]
    def success?
      status == :success
    end

    # Returns true if this is an error response.
    #
    # @return [Boolean]
    def error?
      status == :error
    end

    # Returns true if this response includes a redirect.
    #
    # @return [Boolean]
    def redirect?
      !redirect_path.nil?
    end

    # Returns true if this response includes a download.
    #
    # @return [Boolean]
    def download?
      !file_path.nil?
    end

    # Returns true if this response includes a custom Turbo Stream.
    #
    # @return [Boolean]
    def turbo_stream?
      !turbo_stream_block.nil?
    end
  end
end
