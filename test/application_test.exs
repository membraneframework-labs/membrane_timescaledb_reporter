defmodule Membrane.Telemetry.TimescaleDB do
  use ExUnit.Case
  use Membrane.Telemetry.TimescaleDB.RepoCase

  alias Membrane.Telemetry.TimescaleDB.{Reporter, Event}

  describe "Applications" do
    test "attaches telemetry handler" do

     IO.inspect Event.prefixes() |> Enum.map(& :telemetry.list_handlers(&1))


    end

  end
end
