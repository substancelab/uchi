---
order: 100
---

# Add Uchi to your application

After having installed the gem to your application (See [installation](/installation) instructions) you are ready to configure Uchi.

:::tip Or ask your LLM to do it

> Follow instructions from https://docs.uchiadmin.com/installation/ to add a Uchi admin backend. Generate repositories for all existing models. Reuse existing authentication to lock down the controllers.
:::

:::steps
### Mount Uchi in your application

Add to `config/routes.rb`:

```ruby
  Uchi.routes.mount(self)
```

### Add a repository for one of your models

Assuming you have a `Customer` model with an `id` and a `name` attribute, add the following in `app/uchi/repositories/customer.rb`:

```ruby
module Uchi
  module Repositories
    class Customer < Repository
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

You can learn more about Uchi Repositories in the [Repositories documentation](/repositories).

### Create a controller to handle requests

In `app/controllers/uchi/customers_controller.rb`:

```ruby
module Uchi
  class CustomersController < Uchi::RepositoryController
  end
end
```
:::

Now start your Rails server and visit [http://localhost:3000/uchi/customers](http://localhost:3000/uchi/customers). Welcome to Uchi 😁

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
