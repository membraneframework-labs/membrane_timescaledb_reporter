defmodule Membrane.Telemetry.TimescaleDB.Event do
  @moduledoc """
  Lists all membrane core's event names that are currently being handled.
  """

  @doc """
  Returns event prefixes handled by TimescaleDB reporter.
  """
  @spec prefixes() :: list(list(atom()))
  def prefixes() do
    [
      [:membrane, :input_buffer, :size]
    ]
  end
end
