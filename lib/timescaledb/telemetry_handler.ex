defmodule Membrane.Telemetry.TimescaleDB.TelemetryHandler do
  @moduledoc """
  Declares `handle_event/4` and metrics register functionality required for :telemetry package.
  """

  require Logger
  alias Membrane.Telemetry.TimescaleDB.Reporter

  @doc """
  Handles event names previously registered by `register_metrics/1` and passes them to `Membrane.Telemetry.TimescaleDB.Reporter.send_measurement/2`.
  """
  @spec handle_event(list(atom()), map(), map(), map()) :: :ok
  def handle_event(
        event_name,
        measurement,
        _meta,
        _config
      ) do
    Reporter.send_measurement(event_name, measurement)
  end

  @doc """
  Registers given metrics by attaching `handle_event/4` to :telemetry package.
  Handler is being attached with name returned by `get_handler_name/0`.

  Metrics should be of format `t:Membrane.Telemetry.TimescaleDB.Metrics.metric_t/0`.
  """
  @spec register_metrics(map()) :: :ok | {:error, any}
  def register_metrics(metrics) do
    :telemetry.attach_many(
      get_handler_name(),
      Map.keys(metrics),
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
