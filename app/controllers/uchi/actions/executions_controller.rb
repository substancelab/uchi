# frozen_string_literal: true

module Uchi
  module Actions
    # Controller for creating action executions on repository records.
    #
    # This controller handles POST requests to execute actions registered on
    # repositories. It finds the appropriate action, loads the records, executes
    # the action, and handles the response.
    class ExecutionsController < Uchi::Controller
      def create
        repository = find_repository
        action = find_action(repository: repository)
        input = build_input(action: action)
        records = find_records(repository: repository)

        response = action.handle(records, input)

        handle_response(response: response, repository: repository)
      end

      private

      # Finds and instantiates the repository based on the repository param.
      #
      # @return [Uchi::Repository]
      # @raise [NameError] if the repository class is not found
      def find_repository
        repository_name = params[:repository]
        repository_class_name = "Uchi::Repositories::#{repository_name.camelize}"

        begin
          repository_class = repository_class_name.constantize
        rescue NameError
          raise NameError, "Repository '#{repository_class_name}' not found"
        end

        repository_class.new
      end

      # Finds the action instance on the repository.
      #
      # @param repository [Uchi::Repository] - The repository instance
      # @return [Uchi::Action]
      # @raise [NameError] if the action is not found
      def find_action(repository:)
        action_name = params[:action_name]
        action = repository.actions.find { |a| a.class.name.to_s == action_name }
        return action if action

        raise \
          NameError,
          "Action #{action_name.inspect} not found on " \
          "#{repository.class.name}. Expected one of " \
          "#{repository.actions.map { |a| a.class.name }.join(", ")}"
      end

      # Loads the records to operate on based on the ids or id params.
      #
      # @param repository [Uchi::Repository] - The repository instance
      # @return [ActiveRecord::Relation]
      def find_records(repository:)
        ids = Array(params[:ids] || params[:id])
        repository.find_many(ids)
      end

      # Builds the input hash from params for actions with fields.
      #
      # @param action [Uchi::Action] - The action instance
      # @return [Hash]
      def build_input(action:)
        return {} unless action.requires_input?

        action.fields.each_with_object({}) do |field, hash|
          key = field.name
          hash[key] = params[key] if params.key?(key)
        end
      end

      # Handles the action response by redirecting, sending a file, rendering
      # turbo stream, or falling back to the repository index.
      #
      # @param response [Uchi::ActionResponse] - The action response
      # @param repository [Uchi::Repository] - The repository instance
      def handle_response(response:, repository:)
        flash_key = response.success? ? :success : :alert

        if response.redirect?
          flash[flash_key] = response.message_text if response.message_text
          redirect_to(response.redirect_path, status: :see_other)
        elsif response.download?
          send_file(response.file_path, filename: response.filename)
        elsif response.turbo_stream?
          render(turbo_stream: response.turbo_stream_block.call)
        else
          flash[flash_key] = response.message_text if response.message_text
          redirect_to(
            repository.routes.path_for(:index),
            status: :see_other
          )
        end
      end
    end
  end
end
