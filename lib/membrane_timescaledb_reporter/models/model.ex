defmodule Membrane.Telemetry.TimescaleDB.Model do
  require Logger
  import Ecto.Query
  alias Membrane.Telemetry.TimescaleDB.Repo
  alias Membrane.Telemetry.TimescaleDB.Model.{Measurement, ElementPath, Link}

  # inserts given element paths if they don't exist and returns them, otherwise does nothing
  defp insert_all_element_paths(multi, element_paths) do
    Ecto.Multi.insert_all(multi, :insert_all_element_paths, ElementPath, element_paths,
      on_conflict: :nothing,
      returning: true
    )
  end

  # fetches remaining paths that have not been returned by insert_all_element_paths/2 and bundles them all together
  defp fetch_remaining_paths(multi, element_paths) do
    Ecto.Multi.run(multi, :fetch_remaining_paths, fn repo, changes ->
      %{
        insert_all_element_paths: {_n, inserted_element_paths}
      } = changes

      fetched_paths =
        inserted_element_paths
        |> Enum.map(&%{path: &1.path})
        |> MapSet.new()

      remaining_paths =
        MapSet.new(element_paths) |> MapSet.difference(fetched_paths) |> Enum.map(& &1.path)

      all_paths =
        inserted_element_paths ++
          repo.all(from(ep in ElementPath, where: ep.path in ^remaining_paths))

      {:ok, all_paths}
    end)
  end

  # maps ElementPath's path to corresponding id
  defp map_path_to_id(paths) do
    paths
    |> Enum.map(&{&1.path, &1.id})
    |> Enum.into(%{})
  end

  # remaps all measurements' element_path to corresponding element_path's id and inserts them all
  defp insert_all_measurements(multi, measurements) do
    Ecto.Multi.run(multi, :insert_all_measurements, fn repo,
                                                       %{fetch_remaining_paths: all_paths} ->
      path_to_id = map_path_to_id(all_paths)

      measurements =
        measurements
        |> Enum.map(fn measurement ->
          measurement
          |> Map.put(:element_path_id, path_to_id[measurement.element_path])
          |> Map.drop([:element_path])
        end)

      {inserted, _} = repo.insert_all(Measurement, measurements)
      {:ok, inserted}
    end)
  end

  def add_all_measurements(measurements) do
    element_paths =
      measurements
      |> Enum.map(& &1.element_path)
      |> Enum.uniq()
      |> Enum.map(&%{path: &1})

    try do
      Ecto.Multi.new()
      |> insert_all_element_paths(element_paths)
      |> fetch_remaining_paths(element_paths)
      |> insert_all_measurements(measurements)
      |> Repo.transaction()
    rescue
      error in Postgrex.Error -> {:error, error}
    end
  end

  def add_link(link) do
    Link.changeset(%Link{}, link) |> Repo.insert()
  end
end
