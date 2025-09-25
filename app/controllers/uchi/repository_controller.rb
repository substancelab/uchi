# frozen_string_literal: true

require "pagy"

module Uchi
  class RepositoryController < Uchi::ApplicationController
    include Pagy::Method

    before_action :set_repository

    def create
      @record = build_record
      if @record.save
        redirect_to(@repository.routes.path_for(:show, id: @record.id), notice: "Office created successfully.")
      else
        render :new
      end
    end

    def edit
      @record = find_record
    end

    def index
      if params[:scope]
        # Handle being shown inline in another record's show view
        parent_repository = Uchi::Repository.for_model(params[:scope][:model])&.new
        parent_record = parent_repository.find(params[:scope][:id])
        field_name = params[:scope][:field]
        inverse_of = params[:scope][:inverse_of]&.to_sym

        @columns = @repository.fields_for_index
        @columns = @columns.reject { |field| field.name == inverse_of } if inverse_of

        # TODO: This is very much a security issue. We need to restrict and
        # validate this.
        @records = find_all_records(scope: parent_record.public_send(field_name))
      else
        # Handle the normal case
        @columns = @repository.fields_for_index
        @records = find_all_records
        @pagy, @records = pagy(:offset, @records, limit: index_records_per_page, page: params[:page])
      end
    end

    def new
      @record = build_record
    end

    def show
      @record = find_record
    end

    def update
      @record = find_record
      if @record.update(record_params)
        redirect_to(@repository.routes.path_for(:show, id: @record.id), notice: "Office updated successfully.")
      else
        render :edit
      end
    end

    private

    def build_record
      @repository.build(record_params)
    end

    helper_method def current_sort_order
      @current_sort_order ||= SortOrder.from_params(params) || @repository.default_sort_order
    end

    def find_all_records(scope: nil)
      @repository.find_all(scope: scope, sort_order: current_sort_order)
    end

    def find_record
      @record = @repository.find(params[:id])
    end

    # Returns the number of records per page to show in index views
    def index_records_per_page
      # TODO: Should this be moved to repository?
      25
    end

    def record_params
      editable_fields = @repository.fields_for_edit
      (params[@repository.model_param_key] || ActionController::Parameters.new)
        .permit(editable_fields.map(&:param_key))
    end

    def repository_class
      raise NotImplementedError, "Subclasses must implement repository_class"
    end

    helper_method def scope_params
      if scoped?
        params[:scope].permit(:field, :id, :inverse_of, :model)
      else
        ActionController::Parameters.new
      end
    end

    helper_method def scoped?
      params[:scope].present?
    end

    def set_repository
      @repository = repository_class.new
    end
  end
end
