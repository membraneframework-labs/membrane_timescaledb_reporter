defmodule Membrane.Telemetry.TimescaleDB.Repo.Migrations.MethodToMetricAndElementToComponent do
  use Ecto.Migration

  alias Membrane.Telemetry.TimescaleDB.Repo

  @chunk_time_interval Application.get_env(:membrane_timescaledb_reporter, Repo)[:chunk_time_interval] || "1 minute"
  @chunk_compress_policy_interval Application.get_env(:membrane_timescaledb_reporter,Repo)[:chunk_compress_policy_interval] || "1 minute"

  def up() do
    rename table(:element_paths), to: table(:component_paths)

    execute("CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE")

    drop table(:measurements)

    create table(:measurements, primary_key: false) do
      add(:time, :naive_datetime_usec, null: false, primary_key: true)
      add(:component_path_id, :id, null: false, primary_key: true)
      add(:metric, :string, null: false)
      add(:value, :integer, null: false)
    end

    create index(:measurements, [:time	, :component_path_id])

    execute("SELECT create_hypertable('measurements', 'time', chunk_time_interval => INTERVAL '#{@chunk_time_interval}')")

    execute("""
    ALTER TABLE measurements SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'component_path_id,metric'
    );
    """)

    execute("SELECT add_compress_chunks_policy('measurements', INTERVAL '#{@chunk_compress_policy_interval}')")
  end


  def down() do
    rename table(:component_paths), to: table(:element_paths)

    drop table(:measurements)

    create table(:measurements, primary_key: false) do
      add(:time, :naive_datetime_usec, null: false, primary_key: true)
      add(:element_path_id, :id, null: false, primary_key: true)
      add(:method, :string, null: false)
      add(:value, :integer, null: false)
    end

    create index(:measurements, [:time	, :element_path_id])

    execute("SELECT create_hypertable('measurements', 'time', chunk_time_interval => INTERVAL '#{@chunk_time_interval}')")

    execute("""
    ALTER TABLE measurements SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'element_path_id,method'
    );
    """)

    execute("SELECT add_compress_chunks_policy('measurements', INTERVAL '#{@chunk_compress_policy_interval}')")
  end
end
