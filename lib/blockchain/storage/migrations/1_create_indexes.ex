defmodule StatsCollector.Storage.Migrations.CreateIndexes do
  defmodule Migration do
    @behaviour StatsCollector.Storage.Migration

    def id(), do: "1_create_indexes"

    def up(instance, options) do
      query = %{
        createIndexes: "datadog_events",
        indexes: [
          %{key: %{id: 1}, name: "id_unique_1", unique: true}
        ]
      }

      {:ok, _} = Mongo.command(instance, query, options)
      :ok
    end
  end
end
