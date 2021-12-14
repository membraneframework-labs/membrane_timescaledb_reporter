defmodule Membrane.Telemetry.TimescaleDB.Release do
  @moduledoc """
  Utility module for auto migration.
  """
  require Logger

  @repo Membrane.Telemetry.TimescaleDB.Repo

  @doc """
  Migrates all configured repos.

  Returns true if all repositories migrated successfully, returns false otherwise.
  """
  @spec migrate() :: boolean()
  def migrate do
    case Ecto.Migrator.with_repo(@repo, &Ecto.Migrator.run(&1, :up, all: true)) do
      {:ok, _return, _started_apps} ->
        Logger.info("#{@repo} successfully migrated.")
        true

      _other ->
        false
    end
  end
end
