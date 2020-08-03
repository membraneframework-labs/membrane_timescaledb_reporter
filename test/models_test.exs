defmodule Membrane.Telemetry.TimescaleDB.ModelTest do
  use ExUnit.Case
  use Membrane.Telemetry.TimescaleDB.RepoCase

  alias Membrane.Telemetry.TimescaleDB.Repo
  alias Membrane.Telemetry.TimescaleDB.Model
  alias Membrane.Telemetry.TimescaleDB.Model.{Measurement, ElementPath}

  @measurement %{element_path: "path", method: "method", value: 10}

  defp apply_time(measurement) do
    Map.put(measurement, :time, NaiveDateTime.utc_now())
  end

  describe "Model" do
    test "creates entries in measurements and element_paths tables" do
      assert Enum.empty?(Repo.all(Measurement))
      assert Enum.empty?(Repo.all(ElementPath))

      assert {:ok, %{insert_all_measurements: 1}} =
               Model.add_all_measurements([apply_time(@measurement)])

      assert Enum.count(Repo.all(Measurement)) == 1
      assert Enum.count(Repo.all(ElementPath)) == 1
    end

    test "creates ElementPath uniquely" do
      # create two batches
      1..10 |> Enum.map(fn _ -> apply_time(@measurement) end) |> Model.add_all_measurements()
      1..10 |> Enum.map(fn _ -> apply_time(@measurement) end) |> Model.add_all_measurements()

      assert [element_path] = Repo.all(ElementPath)
      assert element_path.path == @measurement.element_path

      assert Enum.count(Repo.all(Measurement)) == 20
    end

    test "returns error on duplicated measurement" do
      measurement = apply_time(@measurement)
      result = [measurement, measurement] |> Model.add_all_measurements()
      assert {:error, %Postgrex.Error{postgres: %{code: :unique_violation}}} = result
    end
  end
end
