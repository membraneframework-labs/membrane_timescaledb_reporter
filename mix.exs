defmodule Membrane.Telemetry.TimescaleDB.MixProject do
  use Mix.Project

  def project do
    [
      app: :membrane_timescaledb_reporter,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Membrane.Telemetry.TimescaleDB, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:telemetry, "~> 0.4"},
      {:postgrex, ">= 0.0.0"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    ]
  end
end
