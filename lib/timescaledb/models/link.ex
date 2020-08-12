defmodule Membrane.Telemetry.TimescaleDB.Model.Link do
  @moduledoc false
  require Logger
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "links" do
    field(:time, :naive_datetime_usec)
    field(:parent_path, :string)
    field(:from, :string)
    field(:to, :string)
    field(:pad_from, :string)
    field(:pad_to, :string)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :parent_path, :from, :to, :pad_from, :pad_to])
    |> validate_required([:time, :parent_path, :from, :to, :pad_from, :pad_to])
  end
end
