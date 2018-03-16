defmodule Blockchain.MerkleTree do

  def get_merkle_root(txs) do
    grouped_txs = group_txs(txs)
    merkle_tree = calculate_map(to_map(grouped_txs))
    # IO.inspect merkle_tree
    [merkle_root] = Map.keys(merkle_tree)
    merkle_root
  end

  defp group_txs(txs) do
    if rem(length(txs), 2) != 0 do
      txs = txs ++ [List.last(txs)]
      Enum.chunk_every(txs, 2)
    else
      Enum.chunk_every(txs, 2)
    end
  end

  defp to_map(grouped_txs) do
    for tx_pair <- grouped_txs, into: %{}, do: {hash_keys(tx_pair), tx_pair}
  end

  def hash_keys(tx_pair) do
    joined_pair = Enum.join(tx_pair)
    hashed_pair = :crypto.hash(:sha256, joined_pair)
    hashed_pair |> Base.encode16()
  end

  defp calculate_map(map) do
    keys = Map.keys(map)
    cond do
      length(keys) == 1 ->
        map
      length(keys) |> rem(2) != 0 ->
        last_key = List.last(keys)
        calculate_map(Map.put(map, last_key <> "1", []))
      length(keys) |> rem(2) == 0 ->
        keys = Enum.chunk_every(keys, 2)
        map = for k <- keys, into: %{},
          do: {hash_keys(k), (for map_key <- k,
            into: %{}, do: {map_key, map[map_key]})}

        calculate_map(map)
      true ->
        map
    end
  end

end
