---
order: 100
---

# Getting started

## Installation

### 1. Add the gem to your bundle

Add the following to your application's Gemfile:

```ruby
source "https://gems.uchiadmin.com" do
  gem "uchi"
end
```

### 2. Authenticate

You need your private gem server token to download Uchi from the gem server. You can find the token on your project page on [uchiadmin.com/projects](https://www.uchiadmin.com/projects).

You have a few options for authentication with the gem server.

    bundle config set --global gems.uchiadmin.com <your_token_goes_here>

or you can set it as an environment variable:

    BUNDLE_GEMS__UCHIADMIN__COM = <your_token_goes_here>

The latter is probably the easiest and works on your CI and production servers as well.

### 3. Install the gem

And then execute:

```bash
$ bundle install
```

### 2. Create a repository

Add a repository for one of your models in `app/uchi/repositories/customer.rb`:

```ruby
module Uchi
  module Repositories
    class Customer < Repository
      # Returns an array of fields to show for this resource.
      def fields
        [
          Field::Number.new(:id),
          Field::Text.new(:name),
        ]
      end
    end
  end
end
```

### 3. Create a controller to handle requests

In `app/controllers/uchi/customers_controller.rb`:

```ruby
module Uchi
  class CustomersController < Uchi::RepositoryController
  end
end
```

### 4. Route requests to the controller

Add to `config/routes.rb`:

```ruby
  Uchi.routes.mount(self)
```

Now start your Rails server and visit http://localhost:3000/uchi/customers. Welcome to Uchi 😁

### Mounting at a Custom Path

By default, Uchi is mounted at `/uchi`. To use a different path:

```ruby
Rails.application.routes.draw do
  Uchi.routes.mount(self, at: "admin")

  namespace :admin do
    # Your other admin routes
  end
end
```

Now Uchi will be available at `/admin` instead of `/uchi`.
