defmodule Membrane.Telemetry.TimescaleDB.Reporter do
  @moduledoc """
  Receives measurements via `send_measurement/1` then proceedes to cache and eventually flush them to TimescaleDB database.
  """

  use GenServer
  require Logger
  alias Membrane.Telemetry.TimescaleDB.Model

  @log_prefix "[#{__MODULE__}]"

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Sends measurement to GenServer which will cache it and eventually flush it to the database.

  Raises ArgumentError on invalid/unsupported measurement format.
  """
  @spec send_measurement(map()) :: :ok
  def send_measurement(%{element_path: path, method: method, value: value} = measurement)
      when is_binary(path) and is_binary(method) and is_integer(value) do
    GenServer.cast(
      __MODULE__,
      {:measurement, Map.put(measurement, :time, NaiveDateTime.utc_now())}
    )
  end

  def send_measurement(_) do
    raise ArgumentError,
          "#{__MODULE__}: Invalid measurement format, expected map %{element_path: String.t(), method: String.t(), value: integer()"
  end

  @doc """
  Flushes cached measurements to the database.
  """
  @spec flush() :: :ok
  def flush() do
    GenServer.cast(__MODULE__, :flush)
  end

  @doc """
  Returns cached measurements.
  """
  @spec get_cached_measurements() :: list(map())
  def get_cached_measurements() do
    GenServer.call(__MODULE__, :get_cached_measurements)
  end

  @impl true
  def init(_) do
    flush_timeout = Application.get_env(:membrane_timescaledb_reporter, :flush_timeout, 5000)
    flush_threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, 1000)

    Process.send_after(__MODULE__, :force_flush, flush_timeout)
    {:ok, %{measurements: [], flush_timeout: flush_timeout, flush_threshold: flush_threshold}}
  end

  @impl true
  def handle_cast(
        {:measurement, measurement},
        %{measurements: measurements, flush_threshold: flush_threshold} = state
      ) do
    measurements = [measurement | measurements]

    if length(measurements) >= flush_threshold do
      flush_measurements(measurements)
      {:noreply, %{state | measurements: []}}
    else
      {:noreply, %{state | measurements: measurements}}
    end
  end

  def handle_cast(:flush, %{measurements: measurements} = state) do
    flush_measurements(measurements)
    {:noreply, %{state | measurements: []}}
  end

  @impl true
  def handle_call(:get_cached_measurements, _from, %{measurements: measurements} = state) do
    {:reply, measurements, state}
  end

  @impl true
  def handle_info(:force_flush, %{flush_timeout: flush_timeout} = state) do
    Logger.debug("#{@log_prefix} Reached flush timeout: #{flush_timeout}, flushing...")
    flush()
    Process.send_after(__MODULE__, :force_flush, flush_timeout)
    {:noreply, state}
  end

  defp flush_measurements(measurements) when length(measurements) > 0 do
    case Model.add_all_measurements(measurements) do
      {:ok, %{insert_all_measurements: inserted}} ->
        Logger.debug("#{@log_prefix} Flushed #{inserted} measurements")

      {:error, operation, value, changes} ->
        Logger.error("#{@log_prefix} Encountered error: #{operation} #{value} #{changes}")
    end
  end

  defp flush_measurements(_) do
    :ok
  end
end
