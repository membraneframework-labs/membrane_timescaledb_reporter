defmodule Membrane.Telemetry.TimescaleDB.TelemetryHandler do
  require Logger
  alias Membrane.Telemetry.TimescaleDB.Reporter

  def handle_event(
        [:membrane, :input_buffer, :size],
        measurement,
        _meta,
        _config
      ) do
    Reporter.send_measurement(measurement)
  end
end
