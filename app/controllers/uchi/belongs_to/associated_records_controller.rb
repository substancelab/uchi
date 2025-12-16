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
        @repository = Uchi::Repository.for_model(params[:model])&.new
        parent_record = @repository.find(params[:record_id])
        @field_name = params[:field]
        inverse_of = params[:inverse_of]&.to_sym

        # @columns = @repository.fields_for_index
        # @columns = @columns.reject { |field| field.name == inverse_of } if inverse_of
        # @records = find_all_records_from_association(name: field_name, parent_record: parent_record)
        # @paginator, @records = paginate(@records, records_per_page: scoped_records_per_page)
        @records = find_all_records_from_association(name: @field_name, parent_record: parent_record)
        p @records
      end

      private

      def current_sort_order
        Uchi::SortOrder.new(:id, :asc)
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

      def find_all_records_from_association(name:, parent_record:)
        # Duplicated from Uchi::RepositoryController; consider refactoring.

        association = parent_record.class.reflect_on_association(name.to_sym)
        raise NameError, "No association named #{name} on #{parent_record.class}" unless association

        source_repository = Uchi::Repository.for_model(association.active_record)&.new
        raise NameError, "No repository found for scoped model #{association.active_record}" unless source_repository

        associated_repository = Uchi::Repository.for_model(association.klass)&.new
        raise NameError, "No repository found for associated model #{association.klass}" unless associated_repository

        field = source_repository.fields.find { |f| f.name == name.to_sym }
        raise NameError, "No field named #{name} on #{source_repository.model}" unless field

        find_all_records(repository: associated_repository)
      end

    end
  end
end
