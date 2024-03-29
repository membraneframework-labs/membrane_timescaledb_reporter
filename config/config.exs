import Config

# those config values are loaded just for tests
# once the package is included in other project the config
# gets ignored, see: https://hexdocs.pm/elixir/library-guidelines.html#avoid-application-configuration

config :membrane_timescaledb_reporter, ecto_repos: [Membrane.Telemetry.TimescaleDB.Repo]

config :membrane_timescaledb_reporter, Membrane.Telemetry.TimescaleDB.Repo,
  database: "membrane_timescaledb_reporter_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  chunk_time_interval: "10 minutes",
  chunk_compress_policy_interval: "10 minutes"

config :logger, level: :info

config :membrane_timescaledb_reporter,
  reporter_name: "membrane-timescaledb-handler",
  flush_timeout: 15000,
  flush_threshold: 1000
