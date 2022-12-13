defmodule Membrane.Telemetry.TimescaleDB.Repo.Migrations.CreateExtensionTimescaledb do
  use Ecto.Migration

  alias Membrane.Telemetry.TimescaleDB.Repo

  @chunk_time_interval Application.get_env(:membrane_timescaledb_reporter, Repo)[:chunk_time_interval] || "10 minutes"
  @chunk_compress_policy_interval Application.get_env(:membrane_timescaledb_reporter,Repo)[:chunk_compress_policy_interval] || "10 minutes"

  def up() do
    create table(:component_paths) do
      add(:path, :text, null: false)
    end

    create unique_index(:component_paths, :path)

    execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE")


    create table(:measurements, primary_key: false) do
      add(:time, :naive_datetime_usec, null: false)
      add(:component_path_id, references(:component_paths), null: false)
      add(:metric, :string, null: false)
      add(:value, :integer, null: false)
    end

    execute("SELECT create_hypertable('measurements', 'time', chunk_time_interval => INTERVAL '#{@chunk_time_interval}')")

    execute("""
    ALTER TABLE measurements SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'component_path_id,metric'
    );
    """)

    execute("SELECT add_compression_policy('measurements', INTERVAL '#{@chunk_compress_policy_interval}')")
  end


  def down() do
    drop table(:component_paths)
    drop table(:measurements)
    execute("DROP EXTENSION IF EXISTS timescaledb CASCADE")
  end
end
