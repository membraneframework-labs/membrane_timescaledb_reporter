defmodule MembraneTimescaleMetrics do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {MembraneTimescaleMetrics.Repo, []},
      {MembraneTimescaleMetrics.Provider, []}
    ]

    :telemetry.attach(
      "membrane-timescale-handler",
      [:membrane, :buffer, :size],
      &MembraneTimescaleMetrics.TelemetryHandler.handle_event/4,
      nil
    )

    opts = [strategy: :one_for_one, name: :membrane_timescale_metrics]
    Supervisor.start_link(children, opts)
  end
end
