defmodule Membrane.Telemetry.TimescaleDB.TestApplication do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    Application.put_env(:membrane_timescaledb_reporter, :reporters, 1)
    Application.put_env(:membrane_timescaledb_reporter, :auto_migrate?, true)

    children = [Membrane.Telemetry.TimescaleDB]

    opts = [strategy: :one_for_one, name: :membrane_timescaledb_reporter]
    Supervisor.start_link(children, opts)
  end
end
