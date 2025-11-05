# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Labels in the navigation can now be translated. If the navigation-specific translation key isn't set, we'll use the title translation for the repositorys index page.
- The button to add a new model now falls back to the translation from  `common.new` when the button-specific translation doesn't exist before falling back to `"New %{model}"`.
- The button to edit a model now falls back to the translation from `common.edit` when the button-specific translation doesn't exist before falling back to `"Edit"`.
- The button to delete a model now falls back to the translation from  `common.destroy` when the button-specific translation doesn't exist before falling back to `"Delete"`.
- Page title for the new page can now be customized using a `repository.[name].new.title` translation. If that translation isn't present, the title falls back to `repository.[name].button.link_to_new`, and then `common.new` before ultimately falling back to `"New %{model}"`
- Page title for the edit page can now be customized using a `repository.[name].edit.title` translation. If that translation isn't present, the title falls back to `repository.[name].button.link_to_edit`, and then `common.edit` before ultimately falling back to `"Edit %{model}"`

### Fixed

### Removed


## [0.1.4]

### Added

- `Uchi::Repository#title` now dynamically checks for common methods to use as the string representation of a model, ultimately falling back to `#to_s` if none are found.
- `File` field. You can now use the File field to work with Rails ActiveStorage attachments.
- `Image` field. Based on the `File` field it is now possible to upload images to your models and render them inline in Uchi.
- Breadcrumb labels for links to index pages now use the title for the index page if that's been translated. You can still specify a more precise text in `repository.[name].breadcrumb.index.label`.


## [0.1.3]

### Added

- Field::Text for multi-line text content like descriptions, biographies, notes, and comments.
- Field for HasAndBelongsToMany associations.
- Better blank slate when a RecordsTable has no records; we also no longer show page navigation when there are no records.
- A changelog!
- Everything else up until now ;)

### Fixed

- uchi:controller generator now generates proper controller names when name contains multiple words.
