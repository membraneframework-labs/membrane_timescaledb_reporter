defmodule Membrane.Telemetry.TimescaleDB.ReporterTest do
  use Membrane.Telemetry.TimescaleDB.RepoCase

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

  defp apply_time(measurement) do
    Map.put(measurement, :time, NaiveDateTime.utc_now())
  end

  describe "TimescaleDB Reporter inside application" do
    setup do
      Reporter.reset()
    end

    test "sends and caches well formed measurement" do
      assert :ok = Reporter.send_measurement(@metric, @simple_measurement)

      assert [@simple_measurement] = Reporter.get_cached_measurements()
    end

    test "caches messages before reaching threshold" do
      threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, nil)
      measurements_count = div(threshold, 2)

      1..measurements_count
      |> Enum.each(fn _ -> Reporter.send_measurement(@metric, @simple_measurement) end)

      measurements = Reporter.get_cached_measurements()
      assert measurements_count == Enum.count(measurements)
    end

    test "flushes messages on reaching threshold" do
      threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, nil)

      1..div(threshold, 2)
      |> Enum.each(fn _ -> Reporter.send_measurement(@metric, @simple_measurement) end)

      measurements = Reporter.get_cached_measurements()
      assert Enum.count(measurements) == div(threshold, 2)

      1..div(threshold, 2)
      |> Enum.each(fn _ -> Reporter.send_measurement(@metric, @simple_measurement) end)

      measurements = Reporter.get_cached_measurements()
      assert Enum.empty?(measurements)
    end

    test "flushes on request" do
      Reporter.send_measurement(@metric, @simple_measurement)
      assert not Enum.empty?(Reporter.get_cached_measurements())

      Reporter.flush()

      assert Enum.empty?(Reporter.get_cached_measurements())
    end

    test "does not cache link measurement" do
      assert Enum.empty?(Reporter.get_cached_measurements())

      Reporter.send_measurement(@new_link, @simple_link)

      assert Enum.empty?(Reporter.get_cached_measurements())
    end
  end
end
