defmodule Membrane.Telemetry.TimescaleDB do
  @moduledoc """
  Reporter's supervisor responsible for starting a database repository and
  a bunch of reporter's workers.

  Supervisor can be controlled via config variables to determine whether
  the auto migration process should be called or the number of workers that
  should be responsible for handling the events/measurements.

  You can control the config in following way:
  ```
  config :membrane_timescaledb_reporter,
    reporters: 5 # default number of reporter's workers
    auto_migrate?: true # decides if the auto migration should get performed
  ```
  """

  use Supervisor

  alias Membrane.Telemetry.TimescaleDB.Metrics
  alias Membrane.Telemetry.TimescaleDB.Reporter

  @impl true
  def init(_opts) do
    reporters = Application.get_env(:membrane_timescaledb_reporter, :reporters, 5)
    auto_migrate? = Application.get_env(:membrane_timescaledb_reporter, :auto_migrate?, true)

    children = [
      {Membrane.Telemetry.TimescaleDB.Repo, []},
      {Registry, [keys: :unique, name: Reporter.registry()]}
    ]

    auto_migration = maybe_migrate(auto_migrate?)
    workers = specify_reporters(reporters)

    opts = [strategy: :one_for_one, name: :membrane_timescaledb_reporter]

    Supervisor.init(children ++ auto_migration ++ workers, opts)
  end

  @spec active_workers() :: list(pid)
  def active_workers() do
    # from tuples of {id, pid, value} selects pids
    Registry.select(Reporter.registry(), [{{:"$1", :"$2", :"$3"}, [], [:"$2"]}])
  end

  defp maybe_migrate(false), do: []

  defp maybe_migrate(true) do
    [Membrane.Telemetry.TimescaleDB.Release]
  end

  defp specify_reporters(reporters) when is_integer(reporters) and reporters >= 0 do
    for i <- 1..reporters do
      %{
        id: "reporter_#{i}",
        start: {Reporter, :start_link, [[metrics: Metrics.all(), id: i]]},
        type: :worker
      }
    end
  end
end
