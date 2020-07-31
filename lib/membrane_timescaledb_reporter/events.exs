defmodule Membrane.Telemetry.TimescaleDB.Event do
  def prefixes() do
    [
      [:membrane, :input_buffer, :size]
    ]
  end
end
