defmodule Membrane.Telemetry.TimescaleDB.Model.Log do
  @moduledoc """
  Module representing a single log.
  """

  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  @type t :: %__MODULE__{
          time: NaiveDateTime.t() | nil,
          level: String.t(),
          component_path: String.t(),
          message: String.t(),
        }

  @primary_key false
  schema "logs" do
    field(:time, :naive_datetime_usec)
    field(:level, :string)
    field(:component_path, :string)
    field(:message, :string)
  end

  @params [:time, :level, :component_path, :message]

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
