# frozen_string_literal: true

require "uchi/pagination/controller"

module Uchi
  module HasMany
    # Companion controller for the Stimulus-based has_many_controller.
    #
    # Provides backend support for fetching associated records for a has_many
    # field via AJAX.
    class AssociatedRecordsController < Uchi::ApplicationController
      layout false

      def index
        @current_values = field.value(parent_record) || []

        @field_name = params[:field]
        @records = field.collection_query.call(find_all_records_from_association)
      end

      protected

      helper_method def record_title(record)
        return "" if record.nil?

        associated_repository.title(record)
      end

      helper_method def source_repository
        @source_repository ||= begin
          model_name = params[:model]
          repository_class = Uchi::Repository.for_model(model_name)
          raise NameError, "No repository found for model #{model_name}" unless repository_class

          repository_class.new
        end
      end

      private

      def associated_repository
        @associated_repository ||= begin
          associated_repository = Uchi::Repository.for_model(association.klass)&.new
          raise NameError, "No repository found for associated model #{association.klass}" unless associated_repository

          associated_repository
        end
      end

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
            search: params[:query]
          )
      end

      def find_all_records_from_association
        find_all_records(repository: associated_repository)
      end

      def parent_record
        return nil unless params[:record_id].present?

        source_repository.find(params[:record_id])
      end
    end
  end
end
