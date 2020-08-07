defmodule Membrane.Telemetry.TimescaleDB.TelemetryHandler do
  @moduledoc """
  Declares `handle_event/4` and metrics register functionality required for :telemetry package.
  """

  require Logger
  alias Membrane.Telemetry.TimescaleDB.Reporter

  @doc """
  Handles InputBuffer's event and forwards it to `Membrane.Telemetry.TimescaleDB.Reporter`.
  """
  @spec handle_event(list(atom()), map(), map(), map()) :: :ok
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

  Handler is being attached with name returned by `get_handler_name/0`.
  """
  @spec register_metrics(list([atom(), ...])) :: :ok | {:error, any}
  def register_metrics(metrics) do
    :telemetry.attach_many(
      get_handler_name(),
      metrics |> Enum.map(& &1.event_name),
      &handle_event/4,
      nil
    )
  end

  @doc """
  Unregisters handler from :telemetry package.
  """
  @spec unregister_handler :: :ok | {:error, :not_found}
  def unregister_handler() do
    :telemetry.detach(get_handler_name())
  end

  @doc """
  Returns handler name.

  By default it is "membrane-timescaledb-handler" but it can be configured via config.exs.
  """
  @spec get_handler_name() :: any
  def get_handler_name() do
    Application.get_env(
      :membrane_timescaledb_reporter,
      :reporter_name,
      "membrane-timescaledb-handler"
    )
  end
end
