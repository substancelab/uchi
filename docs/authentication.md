# Authentication

Uchi assumes as little as possible about your application, which means authentication is up to your code. This, however, also means you can continue to use whatever authentication mechanism you've already implemented, be it HTTP Basic Authentication, Devise, Rails' authentication generator, or something entirely different.

## Current user

Uchi exposes a [Uchi::Context](/context) instance which includes the currently logged in user.

To expose the current user to Uchi, set the user value in the context in `before_action`:

```ruby
before_action do
  uchi_context.user = Current.session&.user
end
```

## Rails' authentication generator

:::note
While the examples here are based on [Rails' authentication generator](https://guides.rubyonrails.org/security.html#authentication) the patterns should work for pretty much all authentication systems with some modifications.
:::

To restrict access to all Uchi-controllers, add an `Uchi::ApplicationController` at `app/controllers/uchi/application_controller.rb`:

```ruby
module Uchi
  class ApplicationController < Uchi::Controller
  end
end
```

Include the `Authentication` module and provide a `new_session_path` method, which Rails' `Authentication` uses to determine where to send your unauthorized users.

:::tip
To use routes from your application inside the `Uchi` namespace you need to prefix them with `main_app`.
:::

And finally expose the currently logged in user from the session to Uchi's context.

```ruby
module Uchi
  class ApplicationController < Uchi::Controller
    include Authentication

    before_action {
      uchi_context.user = Current.session&.user
    }

    def new_session_path
      main_app.new_session_path
    end
  end
end
```
