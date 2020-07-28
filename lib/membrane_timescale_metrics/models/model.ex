defmodule MembraneTimescaleMetrics.Model do
  require Logger
  import Ecto.Query
  alias MembraneTimescaleMetrics.Repo
  alias MembraneTimescaleMetrics.Model.{Metric, ElementPath}

  def create_all_metrics(metrics) do
    element_paths =
      metrics
      |> Enum.map(& &1.element_path)
      |> Enum.uniq()
      |> Enum.map(&%{path: &1})

    try do
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all_element_paths, ElementPath, element_paths,
        on_conflict: :nothing,
        returning: true
      )
      |> Ecto.Multi.run(:fetch_remaining_paths, fn repo,
                                                   %{
                                                     insert_all_element_paths:
                                                       {_n, inserted_element_paths}
                                                   } ->
        fetched_paths =
          inserted_element_paths
          |> Enum.map(&%{path: &1.path})
          |> MapSet.new()

        remaining_paths =
          MapSet.new(element_paths) |> MapSet.difference(fetched_paths) |> Enum.map(& &1.path)

        path_to_id =
          (inserted_element_paths ++
             repo.all(from(ep in ElementPath, where: ep.path in ^remaining_paths)))
          |> Enum.map(&{&1.path, &1.id})
          |> Enum.into(%{})

        {:ok, path_to_id}
      end)
      |> Ecto.Multi.run(:insert_all_metrics, fn repo, %{fetch_remaining_paths: path_to_id} ->
        metrics =
          metrics
          |> Enum.map(fn metric ->
            metric
            |> Map.put(:element_path_id, path_to_id[metric.element_path])
            |> Map.drop([:element_path])
          end)

        {inserted, _} = repo.insert_all(Metric, metrics)

        {:ok, inserted}
      end)
      |> Repo.transaction()
    rescue
      sth -> Logger.error(inspect(sth))
    end
  end
end
