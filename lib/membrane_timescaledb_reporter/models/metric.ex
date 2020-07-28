defmodule Membrane.Telemetry.TimescaleDB.Model.Metric do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "metrics" do
    field(:time, :naive_datetime_usec)
    field(:element_path_id, :id)
    field(:method, :string)
    field(:value, :integer)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :element_path_id, :method, :value])
    |> validate_required([:time, :element_path_id, :method, :value])
  end
end
