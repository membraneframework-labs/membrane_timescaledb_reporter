defmodule Membrane.Telemetry.TimescaleDB.Metrics do
  @moduledoc """
  Lists all membrane core's metrics that are currently being handled.

  For more information about metric's event names and measurement types please refer to Membrane's Core hex documentation in `Membrane.Telemetry` module.
  """

  @type event_name_t :: [atom(), ...]

  @type metric_t :: %{
          event_name: event_name_t()
        }

  @doc """
  Returns list of metrics hanled by TimescaleDB reporter.
  """
  @spec all() :: list(metric_t())
  def all() do
    [
      %{
        event_name: [:membrane, :input_buffer, :size]
      },
      %{
        event_name: [:membrane, :link, :new]
      }
    ]
  end
end
