defmodule Membrane.Telemetry.TimescaleDB.ReporterTest do
  use Membrane.Telemetry.TimescaleDB.RepoCase

  alias Membrane.Telemetry.TimescaleDB.Reporter

  @simple_measurement %{element_path: "path", method: "method", value: 100}
  @invalid_measurement %{}

  setup do
    # ExUnit by default starts application so to keep Reporter's GenServer state clean just reset it before each test
    Reporter.reset()
  end

  describe "TimescaleDB Reporter" do
    test "sends and stores well formed measurement" do
      assert :ok = Reporter.send_measurement(@simple_measurement)

      assert [@simple_measurement] = Reporter.get_cached_measurements()
    end

    test "caches messages before reaching threshold" do
      threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, nil)
      measurements_count = div(threshold, 2)

      1..measurements_count
      |> Enum.each(fn _ -> Reporter.send_measurement(@simple_measurement) end)

      measurements = Reporter.get_cached_measurements()
      assert measurements_count == Enum.count(measurements)
    end

    test "flushes messages on reaching threshold" do
      threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, nil)

      1..div(threshold, 2)
      |> Enum.each(fn _ -> Reporter.send_measurement(@simple_measurement) end)

      measurements = Reporter.get_cached_measurements()
      assert Enum.count(measurements) == div(threshold, 2)

      1..div(threshold, 2)
      |> Enum.each(fn _ -> Reporter.send_measurement(@simple_measurement) end)

      measurements = Reporter.get_cached_measurements()
      assert Enum.empty?(measurements)
    end

    test "flushes on request" do
      Reporter.send_measurement(@simple_measurement)
      assert not Enum.empty?(Reporter.get_cached_measurements())

      Reporter.flush()

      assert Enum.empty?(Reporter.get_cached_measurements())
    end
  end
end
