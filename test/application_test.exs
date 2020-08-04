defmodule Membrane.Telemetry.TimescaleDB.ApplicationTest do
  use ExUnit.Case
  use Membrane.Telemetry.TimescaleDB.RepoCase

  alias Membrane.Telemetry.TimescaleDB.{Event, Reporter}

  @measurement %{element_path: "handler test", method: "testing", value: 1}

  describe "Application" do
    test "attaches telemetry handler on start" do
      registered_handlers = Event.prefixes() |> Enum.map(&:telemetry.list_handlers(&1))
      assert Event.prefixes() |> Enum.count() == Enum.count(registered_handlers)
    end

    test "handles measurement" do
      event_name = Event.prefixes() |> List.first()

      :telemetry.execute(event_name, @measurement)

      assert [@measurement | _] =  Reporter.get_cached_measurements()
    end
  end
end
