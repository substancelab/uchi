# Authentication

As with everything Uchi tries to assume as little as possible about your application, therefore authentication is also up to you. This means you continue to use whatever authentication mechanism you've already implemented, be it HTTP Basic Authentication, Devise, Rails' authentication generator, or something entirely different.

## Rails' authentication generator

:::note
While the examples here are based on [Rails' authentication generator](https://guides.rubyonrails.org/security.html#authentication) the patterns should work for pretty much all authentication systems with some modifications.
:::

To restrict access to all Uchi-controllers, add an `Uchi::ApplicationController` at `app/controllers/uchi/application_controller.rb`:

```ruby
module Uchi
  class ApplicationController < ActionController::Base
  end
end
```

Include the `Authentication` module and provide a `new_session_path` method, which Rails' `Authentication` uses to determine where to send your unauthorized users.

:::tip
To use routes from your application inside the `Uchi` namespace you need to prefix them with `main_app`.
:::

```ruby
module Uchi
  class ApplicationController < ActionController::Base
    include Authentication

    def new_session_path
      main_app.new_session_path
    end
  end
end
```

## Current user

Uchi exposes a [Uchi::Current](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html) class which includes the currently logged in user at `Uchi::Current.user`.

By default Uchi gets the user using the global `current_user` method, so it should work with Devise and most Rails authentication systems.
