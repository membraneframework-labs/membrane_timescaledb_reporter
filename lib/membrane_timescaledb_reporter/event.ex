defmodule Membrane.Telemetry.TimescaleDB.Event do
  @moduledoc """
  Lists all membrane core's event names that are currently being handled.
  """

  @doc """
  Returns event prefixes hanled by TimescaleDB reporter.
  """
  def prefixes() do
    [
      [:membrane, :input_buffer, :size]
    ]
  end
end
