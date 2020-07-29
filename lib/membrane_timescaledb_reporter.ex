defmodule Membrane.Telemetry.TimescaleDB do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Membrane.Telemetry.TimescaleDB.Repo, []},
      {Membrane.Telemetry.TimescaleDB.Reporter, []}
    ]

    :telemetry.attach(
      Application.get_env(
        :membrane_timescaledb_reporter,
        :reporter_name,
        "membrane-timescaledb-handler"
      ),
      [:membrane, :input_buffer, :size],
      &Membrane.Telemetry.TimescaleDB.TelemetryHandler.handle_event/4,
      nil
    )

    opts = [strategy: :one_for_one, name: :membrane_timescaledb_reporter]
    Supervisor.start_link(children, opts)
  end
end
