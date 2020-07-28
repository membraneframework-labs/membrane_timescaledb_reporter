defmodule MembraneTimescaleMetrics.Model.Metric do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "metrics" do
    field(:time, :naive_datetime_usec)
    field(:element_path_id, :id)
    field(:value, :integer)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :element_path_id, :value])
    |> validate_required([:time, :element_path_id, :value])
  end
end
