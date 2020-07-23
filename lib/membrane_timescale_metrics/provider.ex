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
    IO.puts "Started provider.."
    {:ok, %{metrics: []}}
  end

  def flush() do
    GenServer.cast(__MODULE__, :flush)
  end

  def send_metric(%{pipeline_pid: _pid, element_name: _element_name, value: _value} = metric) do
    GenServer.cast(__MODULE__, {:new_metric, Map.put(metric, :time, NaiveDateTime.utc_now)})
  end

  def send_metric(_) do
    {:error, "invalid metric format, expected map %{pipeline_pid: pid_t(), element_name: String.t(), value: integer()"}
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
    IO.puts "flushing #{length(metrics)} metrics"
    case Model.create_all_metrics(metrics) do
      {:error, changesets} -> IO.puts(inspect(changesets))
      {inserted, _} -> IO.puts("Inserted #{inspect inserted} new metrics")
    end
  end

  def test() do
    1..10000 |> Enum.each(fn n -> send_metric(%{pipeline_pid: "this one", element_name: "this element", value: n}) end)
  end
end
