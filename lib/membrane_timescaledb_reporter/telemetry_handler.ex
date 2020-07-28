defmodule Membrane.Telemetry.TimescaleDB.TelemetryHandler do
  require Logger
  alias Membrane.Telemetry.TimescaleDB.Reporter

  def handle_event(
        [:membrane, :input_buffer, :size],
        %{element_path: _path, method: _method, value: _value} = metric,
        _meta,
        _config
      ) do
    Reporter.send_metric(metric)
  end
end
