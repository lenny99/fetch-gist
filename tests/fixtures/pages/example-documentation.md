# Acme API

The **simple** API for *reliable* widgets.

## Getting started

Install the client with `npm install acme-client`.

Read the [authentication guide](https://docs.example.com/auth) or [API reference](/reference).

### Create a widget

```
const client = new AcmeClient({ token });
const widget = await client.widgets.create({ name: "demo" });
```

### Request options

- **name** is required.
- `color` defaults to `"blue"`.
- Use `dryRun` to validate without saving.

### Response status

1. Send the request.
2. Check the `201` response.
3. Store the returned widget ID.

> Keep API tokens private. Never commit them to source control.

![A widget in the Acme dashboard](/images/widget.png) Use `Ctrl` + `K` to open the command palette.  
The API supports Tom & Jerry names.

This legacy endpoint is deprecated.
