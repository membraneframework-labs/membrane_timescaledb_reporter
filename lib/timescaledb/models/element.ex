defmodule Membrane.Telemetry.TimescaleDB.Model.Element do
  @moduledoc """
  Model used to store information about when elements have been created and then terminated.

  This model may look similar to `ComponentPath` as it may contain the same path but it does much more.
  When element gets created we persist a record with the element's path, time of the event and `terminated` field set to false.
  When elements gets terminated we once again persist the element's path, the time and this time `terminated` field set to true.

  Thanks to the 2 records we can tell when the element was created and terminated therefore telling for how long it had lived.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  schema "elements" do
    field(:time, :naive_datetime_usec)
    field(:path, :string)
    field(:terminated, :boolean)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:time, :path, :terminated])
    |> validate_required([:time, :path, :terminated])
  end
end
