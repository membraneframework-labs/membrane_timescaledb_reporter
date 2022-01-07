defmodule Membrane.Telemetry.TimescaleDB.Repo.Migrations.ElementMetadata do
  use Ecto.Migration

  def change do
    alter table(:elements) do
      add(:metadata, :map, default: %{})
    end
  end
end
