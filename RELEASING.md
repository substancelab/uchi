# Releasing Uchi

Uchi is a commercial gem. It is **not** published to rubygems.org — releases are
pushed to the Uchi Mothership (`https://www.uchiadmin.com`), which serves them
from `https://gems.uchiadmin.com` to projects with an active license.

The gemspec sets `allowed_push_host` to the Mothership, so a stray
`gem push uchi-x.y.z.gem` can never reach rubygems.org.

## One-time setup

Generate a personal API token under **Account** in the Uchi backend at
<https://www.uchiadmin.com/backend>, then make it available to the release
task in one of two ways:

```sh
export UCHI_GEM_PUSH_TOKEN=<your token>
```

or store it in `~/.gem/credentials`:

```sh
gem signin --host https://gems.uchiadmin.com
```

`GEM_HOST_API_KEY` is also honoured, for CI.

## Releasing

1. Bump `Uchi::VERSION` in `lib/uchi/version.rb`.
2. Rename the `## Unreleased` heading in `CHANGELOG.md` to the new version and
   commit. (If you forget, the release notes are taken from `## Unreleased`
   instead and you get a warning.)
3. Run the release:

   ```sh
   bundle exec rake release
   ```

That checks that you have an API token, that the working tree is clean, builds
`pkg/uchi-x.y.z.gem`, creates and pushes the `vx.y.z` tag, and uploads the gem
together with its release notes to the Mothership.

Useful sub-tasks:

| Task | Description |
| --- | --- |
| `rake build` | Build the gem into `pkg/` without releasing it |
| `rake release:changelog` | Print the release notes that would be published |
| `rake release:push` | Upload an already built gem, e.g. after a failed push |

The implementation lives in `rakelib/publish.rb` and `rakelib/publish.rake`,
which are deliberately outside `lib/` so they are not shipped in the gem.

## What the Mothership needs to accept

The push endpoint is the only part of this that lives in the Mothership
repository. `rakelib/publish.rb` expects:

**`POST https://gems.uchiadmin.com/api/v1/gems`**

Authentication
: An `Authorization` header containing the raw API token (no `Bearer` prefix —
  this is how `gem push` does it). Tokens are per user, created and revoked in
  the Uchi backend under Account, and only users allowed to publish should get
  one. Respond `401` or `403` for a bad token; the task turns that into a
  "check your token" message.

Body
: `multipart/form-data` with three parts:

  | Part | Content | Notes |
  | --- | --- | --- |
  | `gem` | the built `.gem` file | filename is `uchi-<version>.gem`, content type `application/octet-stream` |
  | `changelog` | the release notes as Markdown | may be empty |
  | `version` | the version being released | matches the version inside the gem; useful for rejecting mismatches early |

Response
: Any `2xx` is treated as success, and the response body (`text/plain`) is
  printed to the releaser. Anything else aborts the task with the status and
  body included in the error, so return a readable message for the usual
  failures — version already released, gem could not be parsed, token not
  allowed to publish.

Creating the `Release` record from the upload needs nothing new: attaching the
uploaded file and setting `changelog` is enough, since `Release` already
derives `checksum`, `requirements` and `gemspec` from the attached file and
associates itself with the projects holding an active license.
