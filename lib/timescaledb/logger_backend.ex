defmodule Membrane.Telemetry.TimescaleDB.LoggerBackend do
  @behaviour :gen_event

  alias Membrane.Telemetry.TimescaleDB.{Model, Repo}

  @flush_timeout 2_000

  defmodule State do
    defstruct entries: [],
              total: 0,
              threshold: 100
  end


  @impl true
  def init(something) do
    IO.puts("[TIMESCALE LOGGER SETUP] #{inspect(something)}")

    schedule_flush()

    {:ok, %State{}}
  end

  @impl true
  def handle_call({:configure, _options}, state) do
    {:ok, :ok, state}
  end

  @impl true
  def handle_event({level, _gl, {Logger, [_mb_prefix | message], _timestamp, metadata}}, state) do
    path = Keyword.get(metadata, :parent_path) || []
    prefix = Keyword.get(metadata, :mb_prefix)

    if prefix != nil do
      entry = %{
        time: NaiveDateTime.utc_now(),
        level: Atom.to_string(level),
        component_path: extend_with_os_pid(Enum.join(path ++ [prefix], "/")),
        message: Enum.join(message, "")
      }

      state = maybe_handle_entry(entry, state)

      {:ok, state}
    else
      {:ok, state}
    end
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  @impl true
  def handle_info(:force_flush, state) do
    schedule_flush()

    if state.total > 0 do
      {:ok, flush(state)}
    else
      {:ok, state}
    end
  end

  def handle_info(_event, state) do
    {:ok, state}
  end

  @impl true
  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  @impl true
  def terminate(_reason, _state) do
    :ok
  end

  defp schedule_flush() do
    Process.send_after(self(), :force_flush, @flush_timeout)
  end

  # defp parse_timestamp({ymd, {hour, minute, second, mili}}) do
    # NaiveDateTime.from_erl!({ymd, {hour, minute, second}}, {mili * 1_000, 6})
  # end

  defp maybe_handle_entry(entry, state) do
    if state.total + 1 > state.threshold do
      flush(%{state | entries: [entry | state.entries]})
    else
      %{state | entries: [entry | state.entries], total: state.total + 1}
    end
  end

  defp flush(state) do
    Repo.insert_all(Model.Log, Enum.reverse(state.entries))

    %{state | entries: [], total: 0}
  end

  defp extend_with_os_pid(path) do
    String.replace_prefix(path, "pipeline@", "pipeline@#{System.pid()}@")
  end
end
