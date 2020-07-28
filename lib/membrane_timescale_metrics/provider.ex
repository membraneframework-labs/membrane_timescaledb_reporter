defmodule MembraneTimescaleMetrics.Provider do
  use GenServer
  require Logger
  alias MembraneTimescaleMetrics.Model

  @treshold 1000

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{metrics: []}}
  end

  def flush() do
    GenServer.cast(__MODULE__, :flush)
  end

  def send_metric(%{element_path: _path, value: _value} = metric) do
    GenServer.cast(__MODULE__, {:new_metric, Map.put(metric, :time, NaiveDateTime.utc_now())})
  end

  def send_metric(_) do
    {:error,
     "invalid metric format, expected map %{pipeline_name: String.t(), element_name: String.t(), value: integer()"}
  end

  @impl true
  def handle_cast({:new_metric, metric}, %{metrics: metrics} = state) do
    metrics = [metric | metrics]

    if length(metrics) >= @treshold do
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

  defp flush_metrics(metrics) do
    case Model.create_all_metrics(metrics) do
      {:ok, %{insert_all_metrics: inserted}} ->
        Logger.info("[MembraneTimescaleMetrics] Inserted #{inserted} new metrics")
      {:error, operation, value, changes} ->
        Logger.error("[MembraneTimescaleMetrics] Encountered error: #{operation} #{value} #{changes}")
    end
  end

  def test() do
    1..1
    |> Enum.each(fn n ->
      send_metric(%{element_path: "random test element path contianing pipelineo", value: n})
    end)
  end
end
