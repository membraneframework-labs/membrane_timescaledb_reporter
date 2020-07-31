defmodule Membrane.Telemetry.TimescaleDB.RepoCase do
  use ExUnit.CaseTemplate
  alias Membrane.Telemetry.TimescaleDB.Repo

  using do
    quote do
      alias Membrane.Telemetry.TimescaleDB.Repo

      import Ecto
      import Ecto.Query
      import Membrane.Telemetry.TimescaleDB.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Membrane.Telemetry.TimescaleDB.Repo, {:shared, self()})
    end

    :ok
  end
end
