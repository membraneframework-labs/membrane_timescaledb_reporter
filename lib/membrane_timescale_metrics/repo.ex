defmodule MembraneTimescaleMetrics.Repo do
  use Ecto.Repo,
    otp_app: :membrane_timescale_metrics,
    adapter: Ecto.Adapters.Postgres
end
