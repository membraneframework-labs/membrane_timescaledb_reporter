defmodule Membrane.Telemetry.TimescaleDB.Repo.Migrations.Logs do
  use Ecto.Migration

  @chunk_time_interval Application.get_env(:membrane_timescaledb_reporter, Repo)[:chunk_time_interval] || "10 minutes"
  def up do
    create table(:logs, primary_key: false) do
      add(:time, :naive_datetime_usec, null: false)
      add(:level, :string, null: false)
      add(:component_path, :string, null: false)
      add(:message, :text, null: false)
    end

    execute("SELECT create_hypertable('logs', 'time', chunk_time_interval => INTERVAL '#{@chunk_time_interval}')")
  end

  def down do
    drop table(:logs)
  end
end
