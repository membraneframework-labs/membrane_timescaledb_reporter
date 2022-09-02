defmodule Membrane.Telemetry.TimescaleDB.ApplicationTest do
  use Membrane.Telemetry.TimescaleDB.RepoCase, async: false

  alias Membrane.Telemetry.TimescaleDB.{Metrics, Reporter, TelemetryHandler}

  @measurement %{component_path: "handler test", metric: "testing", value: 1}

  describe "Application" do
    setup do
      {:ok, reporter} = Reporter.start(metrics: Metrics.all(), name: Reporter)

      on_exit(fn ->
        :ok = GenServer.stop(reporter)
      end)

      [reporter: reporter]
    end

    test "attaches telemetry handler on start" do
      registered_handlers =
        Metrics.all()
        |> Map.keys()
        |> Enum.flat_map(&:telemetry.list_handlers(&1))
        |> Enum.map(& &1.id)

      assert TelemetryHandler.get_handler_name() in registered_handlers
    end

    test "handles measurement" do
      :telemetry.execute([:membrane, :metric, :value], @measurement)

      measurements =
        Membrane.Telemetry.TimescaleDB.active_workers()
        |> Enum.flat_map(&Reporter.get_cached_measurements(&1))

      assert [@measurement] = measurements
    end
  end
end
