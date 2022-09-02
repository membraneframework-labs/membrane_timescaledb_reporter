Application.put_env(:membrane_timescaledb_reporter, :reporters, 5)
Application.put_env(:membrane_timescaledb_reporter, :auto_migrate?, true)

Membrane.Telemetry.TimescaleDB.TestApplication.start([], [])
ExUnit.start(capture_log: true)
Ecto.Adapters.SQL.Sandbox.mode(Membrane.Telemetry.TimescaleDB.Repo, :manual)
