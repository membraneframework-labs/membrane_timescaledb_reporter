defmodule Membrane.Telemetry.TimescaleDB do
  use Application
  alias Membrane.Telemetry.TimescaleDB.Metrics

  @impl true
  def start(_type, _args) do
    children = [
      {Membrane.Telemetry.TimescaleDB.Repo, []},
      {Membrane.Telemetry.TimescaleDB.Reporter, [metrics: Metrics.all()]}
    ]

    opts = [strategy: :one_for_one, name: :membrane_timescaledb_reporter]
    Supervisor.start_link(children, opts)
  end
end
