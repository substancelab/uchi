---
order: 101
---

# Installation

Uchi can be installed as a gem directly from our private gem server.

:::note
Installing Uchi requires a license with a gem server token for that project. Licenses can be purchased at [uchiadmin.com](https://www.uchiadmin.com) and the gem server token can be found on [uchiadmin.com/projects](https://www.uchiadmin.com/projects).
:::

## Authenticate with the gem server

You have a few options for authentication with the gem server. We recommend using an ENV variable configured for each project.

### Using an ENV variable

    BUNDLE_GEMS__UCHIADMIN__COM=<your_token_goes_here>

The benefit of this is that it works across your deployments - ie both development, CI, and production are likely to have support for ENV variables.

:::warning
You cannot store the variable in  `.env` or similar and expect [dotenv](https://github.com/bkeepers/dotenv) to load it for you. dotenv isn't loaded by bundler thus the ENV variable isn't available when installing.
:::

### Using Bundler config

Alternatively, if you have just one project with Uchi, you can configure the gem server token in your [bundler](https://bundler.io/) installation:

    bundle config set --global gems.uchiadmin.com <your_token_goes_here>

This way it's always available to bundler.

## Install the gem

Add the gem to your application's Gemfile:

```ruby
gem "uchi", source: "https://gems.uchiadmin.com"
```

And then execute:

```bash
$ bundle install
```

## Authenticate and install on CI servers

### GitHub Actions

On [GitHub Actions](https://docs.github.com/en/actions) you can add environment variables to your workflows fairly easily. However, you should treat your private gem server token as a secret, and therefore not expose it publicly. So for this we want to use GitHub Secrets.

1. Under your project's "Settings" in GitHub, go to "Secrets and variables" > "Actions" in the menu.
2. Add a "New repository secret"
3. Use `BUNDLE_GEMS__UCHIADMIN__COM` as the name of the secret and paste your gem server token into the secret.
4. Click "Add secret"

Now you can use that secret in your workflows:

```yaml
name: "Build"

env:
  BUNDLE_GEMS__UCHIADMIN__COM: ${{ secrets.BUNDLE_GEMS__UCHIADMIN__COM }}

jobs:
  # ...
```

Read more about [using secrets in workflows](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets#using-secrets-in-a-workflow).
