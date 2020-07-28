defmodule MembraneTimescaleMetrics.TelemetryHandler do
  require Logger
  alias MembraneTimescaleMetrics.Provider

  def handle_event(
        [:membrane, :buffer, :size],
        %{element_path: _path, value: _value} = metric,
        _meta,
        _config
      ) do
    Provider.send_metric(metric)
  end
end
