defmodule Membrane.Telemetry.TimescaleDB.Model do
  @moduledoc """
  Module responsible for putting data to TimescaleDB.
  """

  import Ecto.Query

  alias Membrane.Telemetry.TimescaleDB.Repo
  alias Membrane.Telemetry.TimescaleDB.Model.{ComponentPath, Element, Measurement, Link}

  require Logger

  @spec add_all_measurements({list(), list(), list()}) ::
          {:ok, non_neg_integer(), map()} | {:error, any()}
  def add_all_measurements({with_paths, without_paths, paths_to_insert}) do
    with {:ok, inserted_paths} <- insert_new_paths(paths_to_insert),
         new_with_paths = prepare_measurements_without_paths(without_paths, inserted_paths),
         {total_inserted, _} <- Repo.insert_all("measurements", with_paths ++ new_with_paths) do
      {:ok, total_inserted, inserted_paths}
     else
      other ->
        {:error, "failed to add measurements #{inspect other}"}
    end
  end

  @spec add_measurement(map()) :: {:ok, Measurement.t()} | {:error, Ecto.Changeset.t()}
  def add_measurement(measurement) do
    %Measurement{}
    |> Measurement.changeset(measurement)
    |> Repo.insert()
  end

  @spec add_link(map()) :: {:ok, Link.t()} | {:error, Ecto.Changeset.t()}
  def add_link(link) do
    %Link{}
    |> Link.changeset(link)
    |> Repo.insert()
  end

  @spec add_element_event(map()) :: {:ok, Element.t()} | {:error, Ecto.Changeset.t()}
  def add_element_event(element) do
    %Element{}
    |> Element.changeset(element)
    |> Repo.insert()
  end

  defp insert_new_paths([]) do
    {:ok, %{}}
  end

  defp insert_new_paths(paths_to_insert) do
    {inserted, paths} =
      ComponentPath
      |> Repo.insert_all(Enum.map(paths_to_insert, &%{path: &1}),
        on_conflict: :nothing,
        returning: true
      )

    # if 'inserted' count is less than the number of paths to insert
    # that means that we got a conflict and some path is already inserted
    # in such case just query non inserted paths for their ids
    already_inserted =
      if length(paths_to_insert) > inserted do
        to_query =
          paths_to_insert
          |> MapSet.new()
          |> MapSet.difference(MapSet.new(paths, & &1.path))
          |> MapSet.to_list()

        from(cp in ComponentPath, where: cp.path in ^to_query)
        |> Repo.all()
      else
        []
      end

    (paths ++ already_inserted)
    |> Map.new(fn el -> {el.path, el.id} end)
    |> then(&{:ok, &1})
  end

  defp prepare_measurements_without_paths(without_paths, inserted_paths) do
    without_paths
    |> Enum.map(fn measurement ->
      measurement
      |> Map.put(:component_path_id, Map.get(inserted_paths, measurement.component_path))
      |> Map.delete(:component_path)
    end)
  end
end
