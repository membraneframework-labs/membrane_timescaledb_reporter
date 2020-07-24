defmodule MembraneTimescaleMetrics.Model do
  use Ecto.Schema
  import Ecto.Changeset
  alias MembraneTimescaleMetrics.Repo

  @primary_key false
  schema "metrics" do
    field(:time, :naive_datetime_usec)
    field(:pipeline_pid, :string)
    field(:element_name, :string)
    field(:value, :integer)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :pipeline_pid, :element_name, :value])
    |> validate_required([:time, :pipeline_pid, :element_name, :value])
  end

  def create_metric(%{time: _time, pipeline_id: _id, element_name: _name, value: _value} = metric) do
    with %Ecto.Changeset{valid?: true} = changeset <- changeset(%__MODULE__{}, metric) do
      case Repo.insert(changeset) do
        {:error, changeset} -> {:error, changeset}
        _ -> :ok
      end
    else
      invalid_changeset -> {:error, invalid_changeset}
    end
  end

  def create_all_metrics(metrics) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, __MODULE__, metrics)
    |> Repo.transaction()
  end
end
