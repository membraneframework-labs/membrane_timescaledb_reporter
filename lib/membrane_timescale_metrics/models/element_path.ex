defmodule MembraneTimescaleMetrics.Model.ElementPath do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "element_paths" do
    field(:path, :string, read_after_writes: true)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:path])
    |> validate_required([:path])
  end
end
