defmodule Membrane.Telemetry.TimescaleDB.ApplicationTest do
  use Membrane.Telemetry.TimescaleDB.RepoCase

  alias Membrane.Telemetry.TimescaleDB.{TelemetryHandler, Metrics, Reporter}

  @measurement %{component_path: "handler test", metric: "testing", value: 1}

  describe "Application" do
    setup do
      Reporter.reset()
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

      assert [@measurement] = Reporter.get_cached_measurements()
    end
  end
end
