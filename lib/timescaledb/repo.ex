defmodule Membrane.Telemetry.TimescaleDB.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :membrane_timescaledb_reporter,
    adapter: Ecto.Adapters.Postgres
end
