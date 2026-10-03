# Context

`Uchi::Context` is a data object with details about the context we're currently executing in. You can use it to see what view we're currently rendering, or what user is logged in (if configured).

Its primary use case is as part of the arguments received by procs used to configure `collection_query`, [`searchable`](/search#customize-search), or [`sortable`](/fields#customize-sorting) options.

Controllers access it via `uchi_context`, repositories and actions via `#context`, and components via `repository.context`.

:::note
All of the attributes can return `nil`
:::

| Attribute | Type | Description |
|---|---|---|
| `user` | `Object` | The current user authenticated in your application, whatever that means in your application. `nil` unless your application sets it, see [Current user](/authentication#current-user). |
| `view` | `Uchi::View` | The view that is being rendered. |
