# Membrane.Telemetry.TimescaleDB

TimescaleDB metrics reporter for [Membrane Core](https://hex.pm/packages/membrane_core).

Reporter attaches itself to [Telemetry](https://hex.pm/packages/telemetry) and listens for events declared and documented in Membrane Core's module `Membrane.Telemetry`.

## Requirements
 - PostgreSQL server instance compatible with TimescaleDB extension.

## Installation

To make use of the reporter you should add it as a dependency with your application besides `membrane_core`.

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `membrane_timescaledb_reporter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_timescaledb_reporter, "~> 0.1.0"}
  ]
end
```


First of all you will need to provide database information inside your `config.exs` e.g: 
```elixir
config :membrane_timescaledb_reporter, Membrane.Telemetry.TimescaleDB.Repo,
  database: "membrane_timescaledb_reporter",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
```

Then you will need to run `ecto.create` and `ecto.migrate` for `Membrane.Telemetry.TimescaleDB.Repo`:
```bash
mix ecto.create -r Membrane.Telemetry.TimescaleDB.Repo && mix ecto.migrate -r Membrane.Telemetry.TimescaleDB.Repo
```

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](
https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

Licensed under the [Apache License, Version 2.0](LICENSE)
