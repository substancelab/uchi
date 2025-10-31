# Repositories

The cornerstones of Uchi are the repositories. This is where you configure what parts of your models you want to expose and how to do it.

## Models

There's a one-to-one mapping between a repository and a model. So if you have a `User` model that you want to include in Uchi, you must have a `User` repository as well.

## Routes

In order to expose your requests to your users, you need a route for each of them. These routes are added to `config/routes.rb` in your main application under the `uchi` namespace:

```ruby
namespace :uchi do
  resources :companies
end
```

See [Rails' routing documentation](https://guides.rubyonrails.org/routing.html) for more details.

### Root URL

If you want to expose a repository at the root URL (ie `/uchi/`) you can configure a [`root`](https://guides.rubyonrails.org/routing.html#using-root) for the namespace:

```ruby
namespace :uchi do
  root "companies#index"
end
```

## Default sort order

Lists of records in a repository are by default sorted by a column called `id`. To customize the default sort order, which is used when a user hasn’t explicitly chosen to sort by a specific field, you can create a `default_sort_order` method in the repository:

```ruby
module Uchi
  class CustomersRepository < Uchi::Repository
    def default_sort_order
      SortOrder.new(:name, :desc)
    end
  end
end
```

`default_sort_order` should return a `Uchi::Repository::SortOrder`.
## Avoiding n+1

To avoid n+1 performance issues on your index pages and other lists, you can set up includes for the repository.

```ruby
module Uchi
  module Repositories
    class User < Repository
      def includes
        [:account]
      end
    end
  end
end
```

See https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes for details.
