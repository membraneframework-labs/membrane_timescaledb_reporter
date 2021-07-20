defmodule Membrane.Telemetry.TimescaleDB.Model.ComponentPath do
  @moduledoc """
  A model representing a component path of an element/bin/pipeline.

  A component path is a string which consists of the following pipeline/bin/element names separated by
  '/' characters.

  The model is used to reduce the space used by the `Measurement` model as
  hundreds of measurements can have the same component path used to identify the source of the measurement
  and instead of storing the whole path string for each measurement we just store the path once and the `Measurement` model
  is responsible for storing just an integer value representing path id.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          path: String.t()
        }

  @primary_key {:id, :id, autogenerate: true}
  schema "component_paths" do
    field(:path, :string)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:path])
    |> validate_required([:path])
    |> unique_constraint(:path)
  end
end
