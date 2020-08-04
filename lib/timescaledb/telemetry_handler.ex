defmodule Membrane.Telemetry.TimescaleDB.TelemetryHandler do
  @moduledoc """
  Declares `handle_event/4` and attach function required for :telemetry package.
  """

  require Logger
  alias Membrane.Telemetry.TimescaleDB.Reporter

  @doc """
  Handles InputBuffer's event and forwards it to `Membrane.Telemetry.TimescaleDB.Reporter`.
  """
  def handle_event(
        [:membrane, :input_buffer, :size],
        measurement,
        _meta,
        _config
      ) do
    Reporter.send_measurement(measurement)
  end

  @doc """
  Attaches `handle_event/4` to :telemetry package.
  """
  def attach_itself() do
    :telemetry.attach(
      Application.get_env(
        :membrane_timescaledb_reporter,
        :reporter_name,
        "membrane-timescaledb-handler"
      ),
      [:membrane, :input_buffer, :size],
      &Membrane.Telemetry.TimescaleDB.TelemetryHandler.handle_event/4,
      nil
    )
  end
end
