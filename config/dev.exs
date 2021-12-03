import Config

config :membrane_timescaledb_reporter, Membrane.Telemetry.TimescaleDB.Repo,
  database: "membrane_timescaledb_reporter",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  chunk_time_interval: "10 minutes",
  chunk_compress_policy_interval: "10 minutes"

config :membrane_timescaledb_reporter, ecto_repos: [Membrane.Telemetry.TimescaleDB.Repo]

config :membrane_timescaledb_reporter,
  reporter_name: "membrane-timescaledb-handler",
  flush_timeout: 5000,
  flush_threshold: 1000
