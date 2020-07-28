defmodule MembraneTimescaleMetrics.Repo.Migrations.CreateExtensionTimescaledb do
  use Ecto.Migration

  def up() do
    execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE")

    create table(:metrics, primary_key: false) do
      add(:time, :naive_datetime_usec, null: false, primary_key: true)
      add(:element_path_id, :id, null: false, primary_key: true)
      add(:value, :integer, null: false)
    end
    # create index(:metrics, [:time	, :element_path_id])

    create table(:element_paths, primary_key: {:id, :id, autogenerate: true}) do
      add(:path, :string, null: false)
    end
    create unique_index(:element_paths, :path)
    execute("SELECT create_hypertable('metrics', 'time', chunk_time_interval => INTERVAL '2 minutes')")

    execute("""
    ALTER TABLE metrics SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'element_path_id'
    );
    """)

    execute("SELECT add_compress_chunks_policy('metrics', INTERVAL '1 minute')")
  end


  def down() do
    drop unique_index(:element_paths, :path)
    drop table(:element_paths)
    drop index(:metrics, [:time, :element_path_id])
    drop table(:metrics)
    execute("DROP EXTENSION IF EXISTS timescaledb CASCADE")
  end

end
