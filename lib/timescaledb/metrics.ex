defmodule Membrane.Telemetry.TimescaleDB.Metrics do
  @moduledoc """
  Lists all membrane core's metrics that are currently being handled.

  For more information about metric's event names and measurement types please refer to Membrane's Core hex documentation in `Membrane.Telemetry` module.
  """

  @type event_name_t :: [atom(), ...]

  @type metrics_t :: %{
          required(event_name_t) => boolean()
        }

  @doc """
  Returns a map of metrics handled by TimescaleDB reporter. Map's key corresponds to event name
  and the value is a boolean telling if the metrics should be cached so that it can be inserted in batches.
  """
  @spec all() :: metrics_t()
  def all() do
    %{
      [:membrane, :metric, :value] => true,
      [:membrane, :link, :new] => false,
      [:membrane, :bin, :init] => false,
      [:membrane, :bin, :terminate] => false,
      [:membrane, :element, :init] => false,
      [:membrane, :element, :terminate] => false
    }
  end
end
