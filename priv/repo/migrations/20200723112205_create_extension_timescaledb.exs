defmodule MembraneTimescaleMetrics.Repo.Migrations.CreateExtensionTimescaledb do
  use Ecto.Migration

  def up() do
    # execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE")

    create table(:metrics, primary_key: false) do
      # timestamps(
      #   updated_at: false,
      #   inserted_at: :time,
      #   type: :naive_datetime_usec,
      #   # WARNING
      #   # TODO: there might be a problem, 2 elements are probabgle to have the same time	, lookup if you can make primary key on timestamp and element name
      #   primary_key: true
      # )

      add(:time, :naive_datetime_usec, null: false, primary_key: true)
      add(:pipeline_pid, :string, null: false)
      # element name in the future might contain information about full element name being created in pipeline
      add(:element_name, :string, null: false, primary_key: true)
      add(:value, :integer, null: false)
    end

    flush()
    create index(:metrics, [:time	, :element_name])

  end

  def down() do
    drop index(:metrics, [:time, :element_name])
    drop table(:metrics)
    execute("DROP EXTENSION IF EXISTS timescaledb CASCADE")
  end

end
