require "test_helper"
require_relative "../../dummy/app/uchi/repositories/author"

class UchiRepositoryTranslateTest < ActiveSupport::TestCase
  def setup
    @repository = Uchi::Repositories::Author.new
    @translate = @repository.translate
    @field = Uchi::Field.new(:name)
  end

  test "initializes with repository" do
    assert_equal @repository, @translate.repository
  end

  test "#breadcrumb_label returns translation from uchi.repository.author.breadcrumb.index.label" do
    I18n.with_locale(:da) do
      result = @translate.breadcrumb_label(:index)
      assert_equal "Forfattere", result
    end
  end

  test "#breadcrumb_label for index page defaults to plural name" do
    result = @translate.breadcrumb_label(:index)
    assert_equal "Authors", result
  end

  test "#breadcrumb_label for show page returns translation from uchi.repository.author.breadcrumb.show.label" do
    I18n.with_locale(:da) do
      result = @translate.breadcrumb_label(:show, record: Author.new(name: "Test Author"))
      assert_equal "Vis Test Author", result
    end
  end

  test "#breadcrumb_label for show page defaults to record title" do
    result = @translate.breadcrumb_label(:show, record: Author.new(name: "Test Author"))
    assert_equal "Test Author", result
  end

  test "#breadcrumb_label for edit page returns translation from uchi.repository.author.breadcrumb.edit.label" do
    I18n.with_locale(:da) do
      result = @translate.breadcrumb_label(:edit, record: Author.new(name: "Test Author"))
      assert_equal "Rediger Test Author", result
    end
  end

  test "#breadcrumb_label for edit page defaults to page name" do
    result = @translate.breadcrumb_label(:edit, record: Author.new(name: "Test Author"))
    assert_equal "Edit", result
  end

  test "#destroy_dialog_title returns translation from uchi.repository.author.dialog.destroy.title" do
    record = Author.new(name: "J. K. Rowling")
    result = @translate.destroy_dialog_title(record)
    assert_equal "Er du sikker på, at du vil slette J. K. Rowling?", result
  end

  test "#destroy_dialog_title falls back to default translation" do
    result = @translate.destroy_dialog_title(:destroy)
    assert_equal "Are you sure?", result
  end

  test "#description returns translation from uchi.repository.author.description.index" do
    result = @translate.description(:index)
    assert_nil result
  end

  test "#description falls back to nil" do
    result = @translate.description(:index)
    assert_nil result
  end

  test "failed_destroy returns translation from uchi.repository.author.destroy.failure" do
    I18n.with_locale(:da) do
      result = @translate.failed_destroy
      assert_equal "Forfatteren kunne ikke slettes", result
    end
  end

  test "failed_destroy falls back to default translation" do
    result = @translate.failed_destroy
    assert_equal "The record could not be deleted", result
  end

  test "#field_label returns translation from uchi.repository.author.field.name.label" do
    I18n.with_locale(:da) do
      result = @translate.field_label(@field)
      assert_equal "Navn", result
    end
  end

  test "#field_label falls back to human_attribute_name" do
    result = @translate.field_label(@field)
    assert_equal "Name", result
  end

  test "#field_hint returns translation from uchi.repository.author.field.name.hint" do
    I18n.with_locale(:da) do
      result = @translate.field_hint(@field)
      assert_equal "Indtast forfatterens navn", result
    end
  end

  test "#field_hint falls back to nil" do
    result = @translate.field_hint(@field)
    assert_nil result
  end

  test "#link_to_cancel returns cancel text" do
    I18n.with_locale(:da) do
      result = @translate.link_to_cancel
      assert_equal "Annuller", result
    end
  end

  test "#link_to_cancel falls back to Cancel" do
    result = @translate.link_to_cancel
    assert_equal "Cancel", result
  end

  test "#link_to_destroy returns destroy text" do
    author = Author.new(name: "Brandon Sanderson")
    I18n.with_locale(:da) do
      result = @translate.link_to_destroy(author)
      assert_equal "Slet Brandon Sanderson", result
    end
  end

  test "#link_to_destroy falls back to delete" do
    author = Author.new(name: "Brandon Sanderson")
    result = @translate.link_to_destroy(author)
    assert_equal "Delete", result
  end

  test "#link_to_edit returns translation from uchi.repository.author.button.link_to_edit" do
    author = Author.new(name: "Test Author")
    I18n.with_locale(:da) do
      result = @translate.link_to_edit(author)
      assert_equal "Rediger", result
    end
  end

  test "#link_to_edit falls back to Edit" do
    author = Author.new(name: "Test Author")
    result = @translate.link_to_edit(author)
    assert_equal "Edit", result
  end

  test "#link_to_new returns translation from uchi.repository.author.button.link_to_new" do
    I18n.with_locale(:da) do
      result = @translate.link_to_new
      assert_equal "Ny forfatter", result
    end
  end

  test "#link_to_new falls back to New %{model}" do
    result = @translate.link_to_new
    assert_equal "New Author", result
  end

  test "#loading_message returns translation from uchi.repository.common.loading" do
    I18n.with_locale(:da) do
      result = @translate.loading_message
      assert_equal "Indlæser...", result
    end
  end

  test "#loading_message falls back to Loading..." do
    result = @translate.loading_message
    assert_equal "Loading...", result
  end

  test "#plural_name returns translation from uchi.repository.author.model with count 2" do
    I18n.with_locale(:da) do
      result = @translate.plural_name
      assert_equal "Forfattere", result
    end
  end

  test "#plural_name falls back to humanized plural model name" do
    result = @translate.plural_name
    assert_equal "Authors", result
  end

  test "#submit_button returns translation from uchi.common.save" do
    I18n.with_locale(:da) do
      result = @translate.submit_button
      assert_equal "Gem", result
    end
  end

  test "#submit_button falls back to Save" do
    result = @translate.submit_button
    assert_equal "Save", result
  end

  test "successful_create returns translation from uchi.repository.author.create.success" do
    I18n.with_locale(:da) do
      result = @translate.successful_create
      assert_equal "Forfatteren er blevet tilføjet", result
    end
  end

  test "successful_create falls back to default translation" do
    result = @translate.successful_create
    assert_equal "Your changes have been saved", result
  end

  test "successful_destroy returns translation from uchi.repository.author.destroy.success" do
    I18n.with_locale(:da) do
      result = @translate.successful_destroy
      assert_equal "Forfatteren er blevet slettet", result
    end
  end

  test "successful_destroy falls back to default translation" do
    result = @translate.successful_destroy
    assert_equal "The record has been deleted", result
  end

  test "successful_update returns translation from uchi.repository.author.update.success" do
    I18n.with_locale(:da) do
      result = @translate.successful_update
      assert_equal "Dine ændringer til forfatteren blev gemt", result
    end
  end

  test "successful_update falls back to default translation" do
    result = @translate.successful_update
    assert_equal "Your changes have been saved", result
  end

  test "#title returns repository title for show page with record" do
    author = Author.new(name: "Test Author")
    result = @translate.title(:show, record: author)
    assert_equal "Test Author", result
  end

  test "#title returns translation from uchi.repository.author.index.title for index page" do
    I18n.with_locale(:da) do
      result = @translate.title(:index)
      assert_equal "Forfattere", result
    end
  end

  test "#title returns translation from uchi.repository.author.edit.title for edit page" do
    I18n.with_locale(:da) do
      result = @translate.title(:edit)
      assert_equal "Rediger forfatter", result
    end
  end

  test "#title returns translation from uchi.repository.author.new.title for new page" do
    I18n.with_locale(:da) do
      result = @translate.title(:new)
      assert_equal "Ny forfatter", result
    end
  end

  test "#title falls back to plural_name" do
    result = @translate.title(:index)
    assert_equal "Authors", result
  end
end
