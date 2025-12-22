# frozen_string_literal: true

require "uchi/pagination/controller"

module Uchi
  module BelongsTo
    # Companion controller for the Stimulus-based belongs_to_controller.
    #
    # Provides backend support for fetching associated records for a belongs_to
    # field via AJAX.
    class AssociatedRecordsController < Uchi::ApplicationController
      layout false

      def index
        @current_value = field.value(parent_record)

        @field_name = params[:field]
        @records = find_all_records_from_association(name: @field_name)
      end

      private

      def association
        @association ||= begin
          association = source_repository.model.reflect_on_association(field.name.to_sym)
          raise NameError, "No association named #{field.name} on #{source_repository.model}" unless association

          association
        end
      end

      def current_sort_order
        Uchi::SortOrder.new(:id, :asc)
      end

      def field
        @field ||= begin
          field_name = params[:field]
          field = source_repository.fields.find { |f| f.name == field_name.to_sym }
          raise NameError, "No field named #{field_name} on #{source_repository.model}" unless field

          field
        end
      end

      def find_all_records(repository:, scope: nil)
        # Duplicated from Uchi::RepositoryController; consider refactoring.
        Rails.logger.debug("Scope: #{scope.inspect}")
        repository
          .find_all(
            scope: scope,
            search: params[:query],
            sort_order: current_sort_order
          )
      end

      def find_all_records_from_association(name:)
        associated_repository = Uchi::Repository.for_model(association.klass)&.new
        raise NameError, "No repository found for associated model #{association.klass}" unless associated_repository

        find_all_records(repository: associated_repository)
      end

      def parent_record
        return nil unless params[:record_id].present?

        source_repository.find(params[:record_id])
      end

      helper_method def source_repository
        @source_repository ||= begin
          model_name = params[:model]
          repository_class = Uchi::Repository.for_model(model_name)
          raise NameError, "No repository found for model #{model_name}" unless repository_class

          repository_class.new
        end
      end
    end
  end
end
