defmodule MembraneTimescaleMetrics.TelemetryHandler do
  require Logger
  alias MembraneTimescaleMetrics.Provider

  def handle_event(
        [:membrane, :buffer, :size],
        %{pipeline_pid: _pid, element_name: _name, value: _value} = metric,
        _meta
      ) do
    Provider.send_metric(metric)
  end
end
