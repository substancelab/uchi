# Translations

Uchi comes with support for I18n and L10n built in. And if you don't want to translate your admin backend, the translation setup can instead be used to customize pretty much all interface elements in whatever language you prefer.

Uchi does not come with any actual translations by default, since this is way too application specific.

We rely on Rails' I18n backend for this, see the [Rails Internationalization (I18n) API guide](https://guides.rubyonrails.org/i18n.html) for details.

## How to add translations

All Uchi-specific translations live under an `uchi` namespace.

Field translations are located under `uchi.repository.[repository name].field.[field name]`. If you want to change the label of a field, use the `label` key, and to set a helpful hint text use the `hint` key. Like so:

```yaml
  uchi:
    repository:
      account:
        field:
          paid_until:
            hint: "When does the account expire?"
            label: "Paid until"
```

## How to translate breadcrumbs

The label of the root item in breadcrumbs can be translated using the translation key `uchi.breadcrumb.root.label`.
