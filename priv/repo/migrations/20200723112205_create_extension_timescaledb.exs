defmodule Membrane.Telemetry.TimescaleDB.Repo.Migrations.CreateExtensionTimescaledb do
  use Ecto.Migration

  alias Membrane.Telemetry.TimescaleDB.Repo

  @chunk_time_interval Application.get_env(:membrane_timescaledb_reporter, Repo)[:chunk_time_interval] || "1 minute"
  @chunk_compress_policy_interval Application.get_env(:membrane_timescaledb_reporter,Repo)[:chunk_compress_policy_interval] || "1 minute"

  def up() do
    execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE")

    create table(:measurements, primary_key: false) do
      add(:time, :naive_datetime_usec, null: false, primary_key: true)
      add(:element_path_id, :id, null: false, primary_key: true)
      add(:method, :string, null: false)
      add(:value, :integer, null: false)
    end
    create index(:measurements, [:time	, :element_path_id])

    create table(:element_paths, primary_key: {:id, :id, autogenerate: true}) do
      add(:path, :string, null: false)
    end
    create unique_index(:element_paths, :path)
    execute("SELECT create_hypertable('measurements', 'time', chunk_time_interval => INTERVAL '#{@chunk_time_interval}')")

    execute("""
    ALTER TABLE measurements SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'element_path_id,method'
    );
    """)

    execute("SELECT add_compress_chunks_policy('measurements', INTERVAL '#{@chunk_compress_policy_interval}')")
  end


  def down() do
    drop table(:element_paths)
    drop table(:measurements)
    execute("DROP EXTENSION IF EXISTS timescaledb CASCADE")
  end

end
