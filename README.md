# Uchi
## Admin framework for Rails applications

## Installation

### 1. Install the gem

Add this line to your application's Gemfile:

```ruby
gem "uchi"
```

And then execute:

```bash
$ bundle
```

### 2. Install Uchi

```bash
$ rails generate uchi:install
```

### 3. Create a repository

Add a repository for one of your models by running

```bash
$ rails generate uchi:repository Customer
```

This adds a repository in `app/uchi/repositories/customer.rb`, a controller to use that repository in `app/controllers/uchi/customers_controller.rb` and a route to `config/routes.rb` to send requests to the controller.

You can now visit http://localhost:3000/uchi/customers - welcome to Uchi :)

Next up; customize your repository to return the fields you want to expose.

## Principles

### Defaults are defaults

Rely on defaults whenever possible. If something has already been decided for us by Rails or Flowbite or Tailwind use their decision.

### I18n is opt in

We don't want to force you to translate everything. If a field doesn't need a translation, don't add one, we'll just fall back to the fields name.

## Repositories

### Model inferrence

There is expected to a one-to-one mapping between repositories and models. Ie we expect one model to exist for each repository.

For the most part the model class for each repository is inferred from the repository class name, ie `Uchi::Repository::User` manages the `User` model. In some cases you might need to specify the relationship explicitly. You can override the `Uchi::Repository.model` class method in that case:

```ruby
class Uchi::Repository::Something < Uchi::Repository
  def self.model
    ::SomethingElse
  end
end
```

## Translations

Everything is localizable and translatable out of the box.

### Fields

Repository fields are translated using translation keys on the form `uchi.repository.<repository name>.field.<field name>`. For example, the translations for a `User` repository could look like:

```yaml
en:
  uchi:
    repository:
      user:
        name: "Name"
        password: "Password"
```

Field translations not specified in the `uchi` scope will default to whatever we get from Rails' `Model#human_attribute_name`.

### Repositories

Repository names are based on the models they manage. Their translation keys are on the form `uchi.repository.<repository name>.model` and should have pluralization options. So a `UserRepository` would look like:

```yaml
en:
  uchi:
    repository:
      user:
        model:
          one: user
          other: users
```

Repository translations will default to whatever we get from Rails' `Model#model_name.human_name`.

### Views

Copy on views can be translated specifically for each view. Their translation keys are on the form `uchi.repository.<repository name>.view.<view name>.<element key>`. For example to translate the "Add" button on the index view for the `UserRepository` you'd use the following translation:

```yaml
en:
  uchi:
    repository:
      user:
        view:
          index:
            add: "Create %{model}"
```

## Authentication

### Basic authentication

The simplest way to lock your admin interface down is to enable basic authentication in your `Uchi::ApplicationController`:

```ruby
module Uchi
  class ApplicationController < Uchi::Controller
    http_basic_authenticate_with :name => "uchi", :password => "rocks"
  end
end
```

See https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic.html for more advanced examples.

## Existing authentication

Uchi exposes a helper method (both in views and controllers) called `#uchi_user`. By default it calls the global `current_user` method, so it should work with Devise and most Rails authentication systems.

In order to require the user to be logged in, you could do something like

```ruby
module Uchi
  class ApplicationController < Uchi::Controller
    before_action :authenticate_user!

    private

    def authenticate_user!
      return if uchi_user

      # Insert more details authentication requirements here, for example:
      # return unless uchi_user && uchi_user.admin?

      redirect_to main_app.new_user_session_path, :alert => "You must be signed in to access this section."
    end
  end
end
```

### Not using `current_user`?

If you expose the current user model via another method name, override the `uchi_user` method in your `Uchi::ApplicationController`:

```ruby
module Uchi
  class ApplicationController < Uchi::Controller
    def uchi_user
      current_employee
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/substancelab/uchi.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Credits

* Uchi contains parts of [Pagy](https://github.com/ddnexus/pagy), Copyright (c) 2017-2025 Domizio Demichelis
