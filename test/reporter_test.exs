defmodule Membrane.Telemetry.TimescaleDB.ReporterTest do
  use Membrane.Telemetry.TimescaleDB.RepoCase

  alias Membrane.Telemetry.TimescaleDB.Metrics
  alias Membrane.Telemetry.TimescaleDB.Reporter

  # event that is being cached by reporter
  @metric [:membrane, :metric, :value]

  # event that is being instatnly flushed to database
  @new_link [:membrane, :link, :new]

  @simple_measurement %{component_path: "path", metric: "metric", value: 100}

  @simple_link %{
    parent_path: "parent_path",
    from: "from",
    to: "to",
    pad_from: "pad_from",
    pad_to: "pad_to"
  }

  describe "TimescaleDB Reporter inside application" do
    setup do
      {:ok, reporter} = Reporter.start(metrics: Metrics.all(), id: "reporter")

      on_exit(fn ->
        :ok = GenServer.stop(reporter)
      end)

      [reporter: reporter]
    end

    test "sends and caches well formed measurement", %{reporter: reporter} do
      assert :ok = Reporter.send_measurement(reporter, @metric, @simple_measurement)

      assert [@simple_measurement] = Reporter.get_cached_measurements(reporter)
    end

    test "caches messages before reaching threshold", %{reporter: reporter} do
      threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, nil)
      measurements_count = div(threshold, 2)

      1..measurements_count
      |> Enum.each(fn _idx ->
        Reporter.send_measurement(reporter, @metric, @simple_measurement)
      end)

      measurements = Reporter.get_cached_measurements(reporter)
      assert measurements_count == Enum.count(measurements)
    end

    test "flushes messages on reaching threshold", %{reporter: reporter} do
      threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, nil)

      1..div(threshold, 2)
      |> Enum.each(fn _idx ->
        Reporter.send_measurement(reporter, @metric, @simple_measurement)
      end)

      measurements = Reporter.get_cached_measurements(reporter)
      assert Enum.count(measurements) == div(threshold, 2)

      1..div(threshold, 2)
      |> Enum.each(fn _idx ->
        Reporter.send_measurement(reporter, @metric, @simple_measurement)
      end)

      measurements = Reporter.get_cached_measurements(reporter)
      assert Enum.empty?(measurements)
    end

    test "flushes on request", %{reporter: reporter} do
      Reporter.send_measurement(reporter, @metric, @simple_measurement)
      assert not Enum.empty?(Reporter.get_cached_measurements(reporter))

      Reporter.flush(reporter)

      assert Enum.empty?(Reporter.get_cached_measurements(reporter))
    end

    test "does not cache link measurement", %{reporter: reporter} do
      assert Enum.empty?(Reporter.get_cached_measurements(reporter))

      Reporter.send_measurement(reporter, @new_link, @simple_link)

      assert Enum.empty?(Reporter.get_cached_measurements(reporter))
    end
  end
end
