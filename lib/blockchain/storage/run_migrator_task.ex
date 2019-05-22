defmodule StatsCollector.Storage.RunMigratorTask do
  alias StatsCollector.Storage.Migrator
  require Logger

  def start_link(instance, options) do
    Task.start_link(__MODULE__, :run, [instance, options])
  end

  def run(instance, options) do
    Logger.info "running migrator..."

    Migrator.up(instance, options)

    Logger.info "migrator completed run..."
  end
end
