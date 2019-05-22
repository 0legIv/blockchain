defmodule StatsCollector.Storage.Migration do
  @callback id() :: String.t()
  @callback up(atom, Keyword.t()) :: :ok
end
