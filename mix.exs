defmodule Membrane.Telemetry.TimescaleDB.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/membraneframework/membrane_timescaledb_reporter"

  def project do
    [
      app: :membrane_timescaledb_reporter,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # hex
      description: "Membrane Multimedia Framework (TimescaleDB metrics reporter)",
      package: package(),

      # docs
      name: "Membrane Telemetry TimescaleDB",
      source_url: @github_url,
      homepage_url: "https://membraneframework.org",
      docs: docs(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, "~> 3.7"},
      {:telemetry, "~> 1.0"},
      {:postgrex, ">= 0.15.13"},
      {:jason, "~> 1.3"},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", LICENSE: [title: "License"]],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [Membrane.Telemetry.TimescaleDB],
      groups_for_modules: [
        "Reporting API": [
          Membrane.Telemetry.TimescaleDB,
          Membrane.Telemetry.TimescaleDB.Reporter,
          Membrane.Telemetry.TimescaleDB.TelemetryHandler,
          Membrane.Telemetry.TimescaleDB.Metrics
        ],
        Database: [
          Membrane.Telemetry.TimescaleDB.Migrator,
          Membrane.Telemetry.TimescaleDB.Model.ComponentPath,
          Membrane.Telemetry.TimescaleDB.Model.Element,
          Membrane.Telemetry.TimescaleDB.Model.Link,
          Membrane.Telemetry.TimescaleDB.Model.Measurement
        ]
      ]
    ]
  end

  defp aliases do
    [
      test: ["ecto.create", "ecto.migrate", "test"]
    ]
  end
end
