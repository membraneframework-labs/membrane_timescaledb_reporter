defmodule Membrane.Telemetry.TimescaleDB.Reporter do
  use GenServer
  require Logger
  alias Membrane.Telemetry.TimescaleDB.Model

  @log_prefix "[#{__MODULE__}]"

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    flush_timeout = Application.get_env(:membrane_timescaledb_reporter, :flush_timeout, 5000)
    flush_threshold = Application.get_env(:membrane_timescaledb_reporter, :flush_threshold, 1000)

    Process.send_after(__MODULE__, :force_flush, flush_timeout)
    {:ok, %{metrics: [], flush_timeout: flush_timeout, flush_threshold: flush_threshold}}
  end

  def flush() do
    GenServer.cast(__MODULE__, :flush)
  end

  def send_metric(%{element_path: _path, method: _metod, value: _value} = metric) do
    GenServer.cast(__MODULE__, {:new_metric, Map.put(metric, :time, NaiveDateTime.utc_now())})
  end

  def send_metric(_) do
    raise "#{__MODULE__}: Invalid metric format, expected map %{element_path: String.t(), method: String.t(), value: integer()"
  end

  defp flush_metrics(metrics) when length(metrics) > 0 do
    case Model.create_all_metrics(metrics) do
      {:ok, %{insert_all_metrics: inserted}} ->
        Logger.debug("#{@log_prefix} Flushed #{inserted} metrics")

      {:error, operation, value, changes} ->
        Logger.error("#{@log_prefix} Encountered error: #{operation} #{value} #{changes}")
    end
  end

  defp flush_metrics(_) do
    :ok
  end

  @impl true
  def handle_cast(
        {:new_metric, metric},
        %{metrics: metrics, flush_threshold: flush_threshold} = state
      ) do
    metrics = [metric | metrics]

    if length(metrics) >= flush_threshold do
      flush_metrics(metrics)
      {:noreply, %{state | metrics: []}}
    else
      {:noreply, %{state | metrics: metrics}}
    end
  end

  def handle_cast(:flush, %{metrics: metrics} = state) do
    flush_metrics(metrics)
    {:noreply, %{state | metrics: []}}
  end

  @impl true
  def handle_info(:force_flush, %{flush_timeout: flush_timeout} = state) do
    Logger.debug("#{@log_prefix} Reached flush timeout: #{flush_timeout}, flushing...")
    flush()
    Process.send_after(__MODULE__, :force_flush, flush_timeout)
    {:noreply, state}
  end
end
