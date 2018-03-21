defmodule Blockchain.MerkleTree do

  @spec get_merkle_root(List.t) :: String.t
  def get_merkle_root(txs) do
    grouped_txs = group_txs(txs)
    merkle_tree = calculate_map(to_map(grouped_txs))
    [merkle_root] = Map.keys(merkle_tree)
    merkle_root
  end

  @doc """
    Creates the merkle tree
  """
  @spec get_merkle_tree(List.t) :: Map.t
  def get_merkle_tree(txs) do
    grouped_txs = group_txs(txs)
    calculate_map(to_map(grouped_txs))
  end

  @spec group_txs(List.t) :: List.t
  defp group_txs(txs) do
    if rem(length(txs), 2) != 0 do
      txs = txs ++ [List.last(txs)] # if number of txs is odd, duplicate the last tx
      Enum.chunk_every(txs, 2) # group the txs by 2
    else
      Enum.chunk_every(txs, 2)
    end
  end

  @spec to_map(List.t) :: Map.t
  defp to_map(grouped_txs) do
    for tx_pair <- grouped_txs, into: %{}, do: {hash_keys(tx_pair), tx_pair}
  end

  @spec hash_keys(List.t) :: String.t
  defp hash_keys(tx_pair) do
    joined_pair = Enum.join(tx_pair)
    hashed_pair = :crypto.hash(:sha256, joined_pair)
    hashed_pair |> Base.encode16()
  end

  @doc """ 
    Calculate the merkle tree
  """
  @spec calculate_map(Map.t) :: Map.t
  defp calculate_map(map) do
    keys = Map.keys(map) # get map keys
    cond do
      length(keys) == 1 -> # if length = 1 we are in the root of the tree
        map
      length(keys) |> rem(2) != 0 ->
        last_key = List.last(keys)
        calculate_map(Map.put(map, last_key <> "1", [])) # if length of list of keys is odd, add to the last "1"
      length(keys) |> rem(2) == 0 -> 
        keys = Enum.chunk_every(keys, 2) # if length of list of keys is even, group them by 2
        map = for k <- keys, into: %{},
          do: {hash_keys(k), (for map_key <- k,
            into: %{}, do: {map_key, map[map_key]})}  # concatenate and hash the keys and add the new key to map 

        calculate_map(map)
      true ->
        map
    end
  end

end
