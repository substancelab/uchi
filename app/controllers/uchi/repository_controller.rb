# frozen_string_literal: true

require "uchi/pagination/controller"

module Uchi
  class RepositoryController < Uchi::ApplicationController
    include Uchi::Pagination::Controller

    before_action :set_repository

    def create
      @record = build_record_for_new
      if save_record_for_new(@record)
        flash[:success] = @repository.translate.successful_create
        redirect_to(path_for_cancel(default: @repository.routes.path_for(:show, id: @record.id)), status: :see_other)
      else
        @fields = fields_for_new(record: @record)
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
      @fields = fields_for_new(record: @record)
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

    # Assigns the foreign key of the scoped parent record to the new record,
    # so that e.g. creating a Title from a Book's show page automatically
    # associates the new Title with that Book.
    #
    # This only applies when the scoped association is backed by a plain
    # foreign key column on the new record (see #scoped_foreign_key). Other
    # kinds of associations (e.g. has_many :through) are handled after the
    # record is saved, by #create_scoped_join_record, since they require the
    # new record to already have an id.
    def assign_scope_to_record(record)
      foreign_key = scoped_foreign_key(record)
      return unless foreign_key

      record.public_send(:"#{foreign_key}=", scope_params[:id])
    end

    # Creates the join record associating the scoped parent record with the
    # given, already saved, record, when the scoped association is a
    # has_many :through (e.g. Company has_many :people, through: :roles).
    #
    # @return [Boolean] true unless creation of the join record was attempted
    #   and failed.
    def create_scoped_join_record(record)
      through = scoped_through_association(record)
      return true unless through

      through[:model].create!(
        through[:parent_key] => scope_params[:id],
        through[:child_key] => record.id
      )
      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    # Returns the fields to show on the new page, excluding the field that
    # represents the scoped parent record's association, since its value is
    # already known and set by #assign_scope_to_record or
    # #create_scoped_join_record.
    def fields_for_new(record:)
      @repository.fields_for_new(record: record).reject { |field| scoped_field?(field: field, record: record) }
    end

    # Returns true if the given field represents the association back to the
    # scoped parent record, whether that's a plain foreign key or a
    # has_many :through join.
    def scoped_field?(field:, record:)
      return true if field.param_key.to_s == scoped_foreign_key(record)

      through = scoped_through_association(record)
      return false unless through

      field_reflection = record.class.reflect_on_association(field.name)
      return false unless field_reflection&.options&.[](:through)

      field_reflection.through_reflection&.klass == through[:model] &&
        field_reflection.klass == scoped_reflection.active_record
    end

    # Returns the association reflection, on the scoped parent record's
    # model, for the scoped field (e.g. Company#reflect_on_association(:people)),
    # or nil if we're not scoped.
    #
    # @return [ActiveRecord::Reflection::AssociationReflection, nil]
    def scoped_reflection
      return nil unless scoped?

      parent_model = scope_params[:model]&.safe_constantize
      return nil unless parent_model

      parent_model.reflect_on_association(scope_params[:field]&.to_sym)
    end

    # Returns the name of the foreign key column, on the given record, that
    # points back to the scoped parent record, or nil if the association
    # can't be represented by a plain foreign key column on this record (e.g.
    # a has_many :through or has_and_belongs_to_many association).
    #
    # The foreign key is derived from the parent record's own association
    # reflection, so it works regardless of whether Rails can automatically
    # infer the inverse association on this side.
    #
    # @return [String, nil]
    def scoped_foreign_key(record)
      reflection = scoped_reflection
      return nil unless reflection
      return nil if reflection.options[:through]

      foreign_key = reflection.foreign_key
      return nil unless record.class.column_names.include?(foreign_key)

      foreign_key
    end

    # Returns the join model and foreign keys needed to associate the given
    # record with the scoped parent record, when the scoped association is a
    # has_many :through (e.g. Company has_many :people, through: :roles).
    #
    # @return [Hash, nil]
    def scoped_through_association(record)
      reflection = scoped_reflection
      return nil unless reflection&.options&.[](:through)

      through_reflection = reflection.through_reflection
      source_reflection = reflection.source_reflection
      return nil unless through_reflection && source_reflection
      return nil unless source_reflection.klass == record.class

      {
        model: through_reflection.klass,
        parent_key: through_reflection.foreign_key,
        child_key: source_reflection.foreign_key
      }
    end

    # Saves the given, newly built, record and, if scoped, associates it with
    # the scoped parent record.
    #
    # Note: does not rely on record.persisted? after the transaction, since
    # ActiveRecord::Rollback does not undo the in-memory state a prior
    # successful #save already set on the record.
    #
    # @return [Boolean] true if the record (and, if applicable, its
    #   association with the scoped parent record) was saved successfully.
    def save_record_for_new(record)
      saved = false
      ActiveRecord::Base.transaction do
        saved = record.save
        raise ActiveRecord::Rollback unless saved

        unless create_scoped_join_record(record)
          saved = false
          raise ActiveRecord::Rollback
        end
      end
      saved
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
