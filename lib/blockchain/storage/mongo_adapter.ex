defmodule Blockchain.Storage.MongoAdapter do

  @mongo_opts [pool: DBConnection.Poolboy, pool_timeout: 60_000, timeout: 60_000]

  def insert_one(mongo_pid, collection, doc, opts \\ [retry: false, rescue_errors: []]) do
    rescue_errors = opts[:rescue_errors] || []

    case Mongo.insert_one(mongo_pid, collection, doc, @mongo_opts) do
      {:ok, insert_result} ->
        {:ok, insert_result}

      {:error, error} ->
        if explain_error(error) in rescue_errors do
          {:ok, :id_unknown}
        else
          {:error, error}
        end
    end
  end

  def aggregate(mongo_pid, collection, query, opts \\ [return_document: :after, retry: true]) do
    Mongo.aggregate(mongo_pid, collection, query, Keyword.merge(opts, @mongo_opts))
  end

  def find_one_and_update(mongo_pid, collection, filter, update, opts \\ [return_document: :after]) do
    map_fn = opts[:map_fn] || fn db_item -> db_item end

    with {:ok, db_item} <- Mongo.find_one_and_update(mongo_pid, collection, filter, update, Keyword.merge(opts, @mongo_opts)) do
      {:ok, map_fn.(db_item)}
    end
  end

  def insert_many(mongo_pid, collection, docs, opts \\ []) do
    Mongo.insert_many(mongo_pid, collection, docs, Keyword.merge(opts, @mongo_opts))
  end

  def delete_many(mongo_pid, collection, filter) do
    Mongo.delete_many(mongo_pid, collection, filter, @mongo_opts)
  end

  def find(mongo_pid, collection, filter, opts \\ [retry: true]) do
    map_fn = opts[:map_fn] || fn db_item -> db_item end
    with %Mongo.Cursor{} = cursor <- Mongo.find(mongo_pid, collection, filter, Keyword.merge(opts, @mongo_opts)) do
      cursor |> Enum.map(map_fn)
    end
  end

  def find_one(mongo_pid, collection, filter, opts \\ [retry: true]) do
    map_fn = opts[:map_fn] || fn db_item -> db_item end
    with %Mongo.Cursor{} = cursor <- Mongo.find_one(mongo_pid, collection, filter, Keyword.merge(opts, @mongo_opts)) do
      cursor |> Enum.map(map_fn)
    end
  end

  def distinct(mongo_pid, collection, field, filter, opts \\ [retry: true]) do
    Mongo.distinct(mongo_pid, collection, field, filter, Keyword.merge(opts, @mongo_opts))
  end

  def aggregation_count(mongo_pid, collection, pipeline \\ [], opts \\ []) do
    do_count(mongo_pid, collection, pipeline, opts)
  end

  def count(mongo_pid, collection, match \\ %{}, opts \\ []) do
    match = %{
      "$match" => match
    }

    do_count(mongo_pid, collection, [match], opts)
  end

  defp do_count(mongo_pid, collection, pipeline, opts) do
    group = %{
      "$group" => %{
        "_id" => nil,
        "count" => %{"$sum" => 1}
      }
    }

    %{"count" => count} =
    mongo_pid
    |> aggregate(collection, pipeline ++ [group], opts)
    |> Enum.at(0, %{"count" => 0})

    count
  end

  def explain_error(%Mongo.Error{code: 11_000}), do: :duplicate_key_error
  def explain_error(error), do: error
end
