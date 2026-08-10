# frozen_string_literal: true

require "uchi/pagination/controller"

module Uchi
  class RepositoryController < Uchi::ApplicationController
    include Uchi::Pagination::Controller

    before_action :set_repository

    def create
      @record = build_record_for_new
      if @record.save
        flash[:success] = @repository.translate.successful_create
        redirect_to(path_for_cancel(default: @repository.routes.path_for(:show, id: @record.id)), status: :see_other)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @record = find_record
      if @record.destroy
        flash[:success] = @repository.translate.successful_destroy
        redirect_to(@repository.routes.path_for(:index), status: :see_other)
      else
        flash[:alert] = @repository.translate.failed_destroy
        redirect_to(@repository.routes.path_for(:show, id: @record.id), status: :see_other)
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
      @record = build_record_for_new
    end

    def show
      @record = find_record
    end

    def update
      @record = find_record
      if @record.update(record_params_for_update)
        flash[:success] = @repository.translate.successful_update
        redirect_to(@repository.routes.path_for(:show, id: @record.id, uniq: rand), status: :see_other)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def build_record_for_new
      record = @repository.build(record_params_for_new)
      assign_scope_to_record(record)
      record
    end

    # Associates the new record with the scoped parent record, so that e.g.
    # creating a Title from a Book's show page automatically associates the
    # new Title with that Book.
    #
    # For a plain has_many/belongs_to, this sets the foreign key column
    # directly. For a collection-based association without one (has_many
    # :through, has_and_belongs_to_many), it assigns the matching *_ids=
    # writer instead (e.g. company_ids=) -- Rails persists that as part of
    # the record's own save, so no separate join record needs to be created
    # here.
    def assign_scope_to_record(record)
      reflection = scoped_reflection
      return unless reflection

      foreign_key = reflection.foreign_key
      if record.class.column_names.include?(foreign_key)
        record.public_send(:"#{foreign_key}=", scope_params[:id])
        return
      end

      child_association = scoped_child_association(record)
      return unless child_association

      record.public_send(:"#{child_association.name.to_s.singularize}_ids=", [scope_params[:id]])
    end

    # Returns the association reflection, on the scoped parent record's
    # model, for the scoped field (e.g. Company#reflect_on_association(:people)).
    #
    # The parent model is validated through the registered repositories.
    #
    # @return [ActiveRecord::Reflection::AssociationReflection, nil]
    def scoped_reflection
      return nil unless scoped?
      return @scoped_reflection if defined?(@scoped_reflection)

      parent_model = Uchi::Repository.for_model(scope_params[:model])&.model
      @scoped_reflection = parent_model&.reflect_on_association(scope_params[:field]&.to_sym)
    end

    # Returns the association, on the given record's model, that mirrors the
    # scoped parent's association back to it (e.g. Person#companies, when the
    # scoped association is Company#people).
    #
    # Assumes conventional Rails naming: that the association is named after
    # the pluralized parent model. This avoids having to identify the
    # has_many :through join model, or has_and_belongs_to_many join table,
    # since Rails only needs the association name to persist either on save.
    #
    # @return [ActiveRecord::Reflection::AssociationReflection, nil]
    def scoped_child_association(record)
      reflection = scoped_reflection
      return nil unless reflection

      guessed_name = reflection.active_record.model_name.plural.to_sym
      child_reflection = record.class.reflect_on_association(guessed_name)
      return nil unless child_reflection&.collection?
      return nil unless child_reflection.klass == reflection.active_record

      child_reflection
    end

    # Returns the path to use for the cancel link
    helper_method def path_for_cancel(default:)
      return default unless scoped?

      parent_model_name = scope[:model]
      parent_repository = Uchi::Repository.for_model(parent_model_name)&.new
      raise NameError, "No repository found for scoped model #{parent_model_name}" unless parent_repository

      parent_model_id = scope[:id]
      parent_repository.routes.path_for(:show, id: parent_model_id)
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

    def permitted_params_for_edit
      @repository.fields_for_edit(record: @record).map(&:permitted_param)
    end

    def permitted_params_for_new
      @repository.fields_for_new(record: @record || @repository.build).map(&:permitted_param)
    end

    def record_params_for_edit
      (params[@repository.model_param_key] || ActionController::Parameters.new)
        .permit(*permitted_params_for_edit)
    end

    def record_params_for_update
      record_params_for_edit
    end

    def record_params_for_new
      (params[@repository.model_param_key] || ActionController::Parameters.new)
        .permit(*permitted_params_for_new)
    end

    # Returns the repository class associated with this controller.
    #
    # For example, Uchi::AuthorsController would return
    # Uchi::Repositories::Author.
    #
    # @return [Class<Uchi::Repository>]
    def repository_class
      return @repository_class if defined?(@repository_class)

      controller_name = self.class.name.demodulize
      base_name = controller_name.sub(/Controller$/, "")
      repository_name = base_name.singularize
      begin
        @repository_class = Uchi::Repositories.const_get(repository_name)
      rescue NameError
        raise \
          NameError,
          "No repository found for controller #{self.class.name}. Expected " \
          "Uchi::Repositories::#{repository_name} to exist. If you want to " \
          "a repository with a different name, override #repository_class in " \
          "your controller."
      end
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
