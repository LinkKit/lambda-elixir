Inspired by [https://github.com/jschoch/exlam](https://github.com/jschoch/exlam)

```
{:lambda, git: "https://github.com/linkkit/lambda-elixir", runtime: false}

MIX_ENV=prod mix lambda.package
MIX_ENV=prod mix lambda.package --umbrella
```

Your elixir application must be running a HTTP server on `:http_shim_port` and emit `SHIM_APPLICATION_STARTED` when started.
