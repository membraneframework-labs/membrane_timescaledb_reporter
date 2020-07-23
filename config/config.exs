import Config

config :membrane_timescale_metrics, MembraneTimescaleMetrics.Repo,
  database: "membrane_timescale_metrics",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :membrane_timescale_metrics, ecto_repos: [MembraneTimescaleMetrics.Repo]
