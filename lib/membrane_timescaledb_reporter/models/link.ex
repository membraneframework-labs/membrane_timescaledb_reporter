defmodule Membrane.Telemetry.TimescaleDB.Model.Link do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "links" do
    field(:time, :naive_datetime_usec)
    field(:parent_path, :string)
    field(:from, :string)
    field(:to, :string)
    field(:via, :string)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :parent_path, :from, :to, :via])
    |> validate_required([:time, :parent_path, :from, :to])
  end
end
