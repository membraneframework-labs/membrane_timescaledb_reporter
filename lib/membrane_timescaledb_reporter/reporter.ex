defmodule Membrane.Telemetry.TimescaleDB.Reporter do
  use GenServer
  require Logger
  alias Membrane.Telemetry.TimescaleDB.Model
  alias Membrane.Telemetry.TimescaleDB.TelemetryHandler

  @log_prefix "[#{__MODULE__}]"

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    metrics =
      opts[:metrics] ||
        raise ArgumentError, "the :metrics options is required by #{inspect(__MODULE__)}"

    GenServer.start_link(__MODULE__, [metrics: metrics], name: __MODULE__)
  end

  @impl true
  def init(metrics: metrics) do
    Process.flag(:trap_exit, true)
    Membrane.Telemetry.TimescaleDB.TelemetryHandler.register_metrics(metrics)

    flush_timeout = Application.get_env(:membrane_timescaledb_reporter, :flush_timeout, 5000)
    flush_threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, 1000)

    Process.send_after(__MODULE__, :force_flush, flush_timeout)

    {:ok,
     %{
       measurements: [],
       flush_timeout: flush_timeout,
       flush_threshold: flush_threshold,
       metrics: metrics
     }}
  end

  def flush() do
    GenServer.cast(__MODULE__, :flush)
  end

  def reset() do
    GenServer.cast(__MODULE__, :reset)
  end

  def get_metrics() do
    GenServer.call(__MODULE__, :metrics)
  end

  @spec send_measurement(list(atom()), map()) :: :ok
  def send_measurement(event_name, measurement)

  def send_measurement(
        [:membrane, :input_buffer, :size],
        %{element_path: path, method: method, value: value} = measurement
      )
      when is_binary(path) and is_binary(method) and is_integer(value) do
    GenServer.cast(
      __MODULE__,
      {:measurement, Map.put(measurement, :time, NaiveDateTime.utc_now())}
    )
  end

  def send_measurement(event_name, measurement) do
    Logger.warn(
      "#{__MODULE__}: Either event name: #{inspect(event_name)} or measurement format: #{
        inspect(measurement)
      } is not being supported"
    )
  end

  def send_link(%{parent_path: parent_path, from: from, to: to, pad_from: pad_from, pad_to: pad_to} = link)
      when is_binary(parent_path) and is_binary(from) and is_binary(to) and is_binary(pad_from) and is_binary(pad_to) do
    GenServer.cast(
      __MODULE__,
      {:link, Map.put(link, :time, NaiveDateTime.utc_now())}
    )
  end

  def send_link(invalid_link) do
    Logger.warn("#{__MODULE__} Invalid link format: #{inspect(invalid_link)}")
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

  def get_cached_measurements() do
    GenServer.call(__MODULE__, :get_cached_measurements)
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

  def handle_cast({:link, link}, state) do
    case Model.add_link(link) do
      {:ok, _} ->
        Logger.debug("#{@log_prefix} Added new link")

      {:error, reason} ->
        Logger.error("#{@log_prefix} Error while adding new link: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  def handle_cast(:flush, %{measurements: measurements} = state) do
    flush_measurements(measurements)
    {:noreply, %{state | measurements: []}}
  end

  def handle_cast(:reset, state) do
    {:noreply, %{state | measurements: []}}
  end

  @impl true
  def handle_call(:get_cached_measurements, _from, %{measurements: measurements} = state) do
    {:reply, measurements, state}
  end

  def handle_call(:metrics, _from, %{metrics: metrics} = state) do
    {:reply, metrics, state}
  end

  @impl true
  def handle_info(:force_flush, %{flush_timeout: flush_timeout} = state) do
    Logger.debug("#{@log_prefix} Reached flush timeout: #{flush_timeout}, flushing...")
    flush()
    Process.send_after(__MODULE__, :force_flush, flush_timeout)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.error(
      "#{__MODULE__}.terminate/2 called with reason #{inspect(reason)}, unregistering handler"
    )

    TelemetryHandler.unregister_handler()
  end
end
