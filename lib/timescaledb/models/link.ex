defmodule Membrane.Telemetry.TimescaleDB.Model.Link do
  @moduledoc """
  Module representing a single link between membrane bins/elements.

  Each link is represented by a parent path of the linked elements,
  from/to elements names and on what pads of the elements the link gets created.
  """

  use Ecto.Schema

  import Ecto.Changeset

  require Logger

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
