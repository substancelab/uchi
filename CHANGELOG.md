# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Uchi::Repository#title` now dynamically checks for common methods to use as the string representation of a model, ultimately falling back to `#to_s` if none are found.
- `File` field. You can now use the File field to work with Rails ActiveStorage attachments.
- `Image` field. Based on the `File` field it is now possible to upload images to your models and render them inline in Uchi.

### Fixed

### Removed


## [0.1.3]

### Added

- Field::Text for multi-line text content like descriptions, biographies, notes, and comments.
- Field for HasAndBelongsToMany associations.
- Better blank slate when a RecordsTable has no records; we also no longer show page navigation when there are no records.
- A changelog!
- Everything else up until now ;)

### Fixed

- uchi:controller generator now generates proper controller names when name contains multiple words.
