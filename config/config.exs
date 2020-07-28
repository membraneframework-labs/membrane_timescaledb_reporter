import Config

config :membrane_timescaledb_reporter, Membrane.Telemetry.TimescaleDB.Repo,
  database: "membrane_timescaledb_reporter",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :membrane_timescaledb_reporter, ecto_repos: [Membrane.Telemetry.TimescaleDB.Repo]

config :membrane_timescaledb_reporter,
  reporter_name: "membrane-timescaledb-handler",
  metrics_buffer_size: 1000
