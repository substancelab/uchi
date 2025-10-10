# frozen_string_literal: true

require "uchi/pagination/controller"

module Uchi
  class RepositoryController < Uchi::ApplicationController
    include Uchi::Pagination::Controller

    before_action :set_repository

    def create
      @record = build_record
      if @record.save
        flash[:notice] = @repository.translate.successful_create
        redirect_to(@repository.routes.path_for(:show, id: @record.id), status: :see_other)
      else
        render :new, status: :unprocessable_entity
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
        @records = find_all_records_from_association(name: field_name, parent_record: parent_record)
        @paginator, @records = paginate(@records, records_per_page: scoped_records_per_page)
      else
        # Handle the normal case
        @columns = @repository.fields_for_index
        @records = find_all_records
        @paginator, @records = paginate(@records, records_per_page: index_records_per_page)
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
        flash[:notice] = @repository.translate.successful_update
        redirect_to(@repository.routes.path_for(:show, id: @record.id), status: :see_other)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def build_record
      @repository.build(record_params)
    end

    # Returns the path to use for the cancel link
    helper_method def path_for_cancel(default:)
      return params[:cancel_to] if params[:cancel_to].present?

      if scoped?
        parent_model_name = scope[:model]
        parent_repository = Uchi::Repository.for_model(parent_model_name)&.new
        raise NameError, "No repository found for scoped model #{parent_model_name}" unless parent_repository

        parent_model_id = scope[:id]
        return parent_repository.routes.path_for(:show, id: parent_model_id)
      end

      default
    end

    helper_method def current_sort_order
      @current_sort_order ||= SortOrder.from_params(params) || @repository.default_sort_order
    end

    def find_all_records(scope: nil)
      @repository
        .find_all(
          scope: scope,
          search: params[:query],
          sort_order: current_sort_order
        )
    end

    def find_all_records_from_association(name:, parent_record:)
      association = parent_record.class.reflect_on_association(name.to_sym)
      raise NameError, "No association named #{name} on #{parent_record.class}" unless association

      source_repository = Uchi::Repository.for_model(association.active_record)&.new
      raise NameError, "No repository found for scoped model #{association.active_record}" unless source_repository

      associated_repository = Uchi::Repository.for_model(association.klass)&.new
      raise NameError, "No repository found for associated model #{association.klass}" unless associated_repository

      field = source_repository.fields.find { |f| f.name == name.to_sym }
      raise NameError, "No field named #{name} on #{source_repository.model}" unless field

      scope = parent_record.association(name.to_sym).scope
      find_all_records(scope: scope)
    end

    def find_record
      @record = @repository.find(params[:id])
    end

    # Returns the number of records per page to show in index views
    def index_records_per_page
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
        scope.permit(:field, :id, :inverse_of, :model)
      else
        ActionController::Parameters.new
      end
    end

    # Returns the scope that we're currently operating within, if any.
    def scope
      params[:scope]
    end

    helper_method def scoped?
      scope.present?
    end

    def scoped_records_per_page
      5
    end

    def set_repository
      @repository = repository_class.new
    end
  end
end
