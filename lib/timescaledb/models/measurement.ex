defmodule Membrane.Telemetry.TimescaleDB.Model.Measurement do
  @moduledoc """
  Model representing a single measurement of an arbitrary metric.

  Besides metric name and measurement value, the record takes a component_path_id to identify the source
  of the measurement, for more go see `ComponentPath` model's doc.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          time: NaiveDateTime.t(),
          component_path_id: non_neg_integer(),
          metric: String.t(),
          value: integer()
        }

  @primary_key false
  schema "measurements" do
    field(:time, :naive_datetime_usec)
    field(:component_path_id, :id)
    field(:metric, :string)
    field(:value, :integer)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :component_path_id, :metric, :value])
    |> validate_required([:time, :component_path_id, :metric, :value])
  end
end
