defmodule Membrane.Telemetry.TimescaleDB.TelemetryHandler do
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

  def handle_event(
        event_name,
        _value,
        _meta,
        _config
      ) do
    Logger.warn(
      "#{__MODULE__}: #{inspect(event_name)} has been registered but is not being handled by TimescaleDB.Reporter"
    )
  end

  @doc """
  Registers given metrics by attaching `handle_event/4` to :telemetry package.
  """
  @spec register_metrics(list([atom(), ...])) :: :ok | {:error, any}
  def register_metrics(metrics) do
    :telemetry.attach_many(
      get_handler_name(),
      metrics |> Enum.group_by(& &1.event_name) |> Map.keys(),
      &handle_event/4,
      nil
    )
  end

  def unregister_handler() do
    :telemetry.detach(get_handler_name())
  end

  def get_handler_name() do
    Application.get_env(
      :membrane_timescaledb_reporter,
      :reporter_name,
      "membrane-timescaledb-handler"
    )
  end
end
