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
    field(:pad_from, :string)
    field(:pad_to, :string)
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :parent_path, :from, :to, :via, :pad_from, :pad_to])
    |> validate_required([:time, :parent_path, :from, :to, :pad_from, :pad_to])
  end
end
