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

## How to configure the repository for a controller

Each repository is exposed to the user via a controller. For the vast majority of cases Uchi guesses the repository to use for a given controller, but in case you have special requirements, you can override the `#repository_class` method in your controller:

```ruby
module Uchi
  class UsbController < Uchi::RepositoryController

    def repository_class
      Uchi::Repositories::USB
    end
  end
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

## Customizing the title of a record

When a model is rendered in the UI, we call the `#title` method on the repository for that model. By default `#title` returns the value of the first of the following methods that exists on the model:

1. `#name`
2. `#title`
3. `#to_s`

If none of those return a suitable value for your model, you can override the `#title` method in your repository to return a better value:

```ruby
  def title(record)
    return nil unless record

    record.original_title
  end
```
