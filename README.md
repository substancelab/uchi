# Uchi
## Admin framework for Rails applications

Build usable and extensible admin panels for your Ruby on Rails application in minutes.

Level up your scaffolds with a modern admin backend framework, designed for Rails developers who demand both beauty, functionality, and extensibility. Uchi provides a set of components and conventions for creating user interfaces that are both powerful and easy to use.

## Installation

### 1. Install the gem

Uchi is distributed from a private gem server and requires a license. See the [installation docs](https://docs.uchiadmin.com/installation) for how to authenticate with the gem server.

Add this line to your application's Gemfile:

```ruby
gem "uchi", source: "https://gems.uchiadmin.com"
```

And then execute:

```bash
$ bundle
```

### 2. Install Uchi

```bash
$ rails generate uchi:install
```

This mounts Uchi in `config/routes.rb`.

### 3. Create a repository

Add a repository for one of your models by running

```bash
$ rails generate uchi:repository Customer
```

This adds a repository in `app/uchi/repositories/customer.rb` and a controller to use that repository in `app/controllers/uchi/customers_controller.rb`. Routes are drawn automatically for every repository.

You can now visit http://localhost:3000/uchi/customers - welcome to Uchi :)

Next up; customize your repository to return the fields you want to expose.

## Fields

Each repository defines a method, `#fields`, that returns the fields to include in the views in that repository. For example, a `Customer` repository could return its fields as:

```ruby
class Uchi::Repositories::Customer < Uchi::Repository
  def fields
    [
      Field::String.new(:name),
      Field::Date.new(:started_on),
      Field::BelongsTo.new(:company),
      Field::HasMany.new(:agreements),
    ]
  end
end
```

Uchi comes with a bunch of fields that you can choose from, fx:

- `Field::BelongsTo`
- `Field::Boolean`
- `Field::Date`
- `Field::DateTime`
- `Field::File`
- `Field::HasAndBelongsToMany`
- `Field::HasMany`
- `Field::Id`
- `Field::Image`
- `Field::Number`
- `Field::Select`
- `Field::String`
- `Field::Text`

If none of the above works for you, you can create your own and use those.

For more details about fields see the [Fields documentation](docs/fields.md).

## Repositories

The cornerstones of Uchi are the repositories. This is where you configure what parts of your models you want to expose and how to do it.

There's a one-to-one mapping between a repository and a model. So if you have a `User` model that you want to include in Uchi, you must have a `User` repository as well.

### Model inference

For the most part the model class for each repository is inferred from the repository class name, ie `Uchi::Repositories::User` manages the `User` model. In some cases you might need to specify the relationship explicitly. You can override the `Uchi::Repository.model` class method in that case:

```ruby
class Uchi::Repositories::Something < Uchi::Repository
  def self.model
    ::SomethingElse
  end
end
```

For more details about repositories see the [Repositories documentation](docs/repositories.md).

## Translations

Everything is localizable and translatable out of the box.

### Fields

Repository field labels are translated using translation keys on the form `uchi.repository.<repository name>.field.<field name>.label`. For example, the translations for a `User` repository could look like:

```yaml
en:
  uchi:
    repository:
      user:
        field:
          name:
            label: "Name"
          password:
            label: "Password"
```

Field translations not specified in the `uchi` scope will default to whatever we get from Rails' `Model#human_attribute_name`.

### Repositories

Repository names are based on the models they manage. Their translation keys are on the form `uchi.repository.<repository name>.model` and should have pluralization options. So the `User` repository would look like:

```yaml
en:
  uchi:
    repository:
      user:
        model:
          one: user
          other: users
```

Repository translations default to the model's name as provided by Rails' `Model.model_name`.

### Buttons

Buttons can be translated specifically for each repository. Their translation keys are on the form `uchi.repository.<repository name>.button.<button key>`. For example to translate the "New" button on the index view for the `User` repository you'd use the following translation:

```yaml
en:
  uchi:
    repository:
      user:
        button:
          link_to_new: "Create %{model}"
```

Button translations not specified for a repository fall back to `uchi.common`, ie `uchi.common.new`.

## Authentication

Uchi assumes as little as possible about your application, which means authentication is up to your code. See [the authentication docs](https://docs.uchiadmin.com/authentication) for details.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/substancelab/uchi.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, rename the `## Unreleased` heading in `CHANGELOG.md` to the new version, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file and its release notes to the Uchi Mothership at [gems.uchiadmin.com](https://gems.uchiadmin.com). Uchi is not published to rubygems.org. See [RELEASING.md](RELEASING.md) for the required API token and details.

### Running tests against different databases

The test suite runs against SQLite by default. To run it against MySQL or PostgreSQL, set `DB` to `mysql` or `postgres` (plus `DATABASE_HOST`/`DATABASE_USERNAME`/`DATABASE_PASSWORD` if they differ from the defaults in `test/dummy/config/database.yml`):

```
DB=mysql bundle exec rake app:test
```

See `.github/workflows/build.yml` for the service containers CI uses for each database.

## Release

1. Make sure tests pass: `$ rake app:test`
2. Make sure herb lint passes: `$ rake herb:lint`
3. Make sure standard passes: `$ rake app:standard`
4. Verify the [most recent build on `main`](https://github.com/substancelab/uchi/actions?query=branch%3Amain) is green.

All green? Then you are ready to release.

1. Build the gem: `rake assets:build build`.
2. Update `Uchi::VERSION` in `lib/uchi/version.rb` with the version you want to release.
3. Update `CHANGELOG.md`: Add a version reference to the list at the bottom and replace the `Unreleased` header with the new version number.
4. Commit these changes: `$ git commit -am "Release 0.4.0"`
5. Release to Mothership: `$ rake release`

After release, a few administrative tasks:

1. Deploy the documentation site: https://hatchbox.io/apps/13315-uchi-docs
2. Upgrade the demo site to the new version: https://github.com/substancelab/uchi-demo-crm/

## Principles

### Defaults are defaults

Rely on defaults whenever possible. If something has already been decided for us by Rails or Flowbite or Tailwind use their decision.

### I18n is opt in

We don't want to force you to translate everything. If a field doesn't need a translation, don't add one, we'll just fall back to the fields name.

### Edits happen on the edit page

This includes both attributes and associations as much as feasible.

### Fewer assumptions

We try to make as few assumptions about the consumer application as possible; even if it means the consumer has to be a bit more explicit in their code.

### Be database agnostic

We support the same DBMSs as ActiveRecord does.

## Credits

* Uchi contains parts of [Pagy](https://github.com/ddnexus/pagy), Copyright (c) 2017-2025 Domizio Demichelis
* Uchi contains parts of [Flowbite Components](https://github.com/substancelab/flowbite-components), Copyright (c) 2025 Substance Lab
* Uchi uses [combobox-nav](https://github.com/github/combobox-nav), Copyright (c) 2018 GitHub
* Uchi uses [requestjs-rails](https://github.com/rails/requestjs-rails), Copyright (c) 2021 Marcelo Lauxen
* Uchi uses [stimulus-use](https://github.com/stimulus-use/stimulus-use), Copyright (c) 2020 Adrien POLY
