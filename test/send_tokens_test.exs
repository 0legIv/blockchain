defmodule SendTokensTest do
  use ExUnit.Case

  alias Blockchain
  alias Blockchain.Structures.Tx
  alias Blockchain.Miner
  alias Blockchain.Wallet
  alias Blockchain.Keys
  alias Blockchain.TxsPool
  alias Blockchain.Chain



  test "send_tokens" do
     public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
     Wallet.send_tokens(Keys.get_miner_public_key, public_key1, 5, Keys.get_miner_private_key)
     Miner.mine_single_block()
     chain_txs = for x <- Chain.get_state, do: x.txs_list
     filtered_tx = for bl <- List.flatten(chain_txs),
      bl.from_acc == Keys.get_miner_public_key,
      bl.to_acc == public_key1,
      do: bl.id

     assert filtered_tx != []
     # assert Enum.member?(checked_txs, chain_txs)
  end

  test "invalid_send_tokens" do
    public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
    Wallet.send_tokens(Keys.get_miner_public_key, public_key1, 5, Keys.get_private_key1) # different private key, so sign for tx will be invalid
    Miner.mine_single_block()
    chain_txs = for x <- Chain.get_state, do: x.txs_list
    filtered_tx = for bl <- List.flatten(chain_txs),
     bl.from_acc == Keys.get_miner_public_key,
     bl.to_acc == public_key1,
     do: bl.id

    assert filtered_tx == []
  end

  # def send_token_test(0) do
  #   []
  # end
  #
  # def send_token_test(counter) do
  #   entropy_byte_size = 16
  #   public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
  #   public_key2 = Keys.get_private_key2() |> Keys.generate_public_key()
  #   public_key3 = Keys.get_private_key3() |> Keys.generate_public_key()
  #   send_tokens(Keys.get_miner_public_key, public_key1, 5, Keys.get_miner_private_key)
  #   send_tokens(public_key1, public_key2, 3, Keys.get_private_key1())
  #   send_tokens(public_key2, public_key3, 2, Keys.get_private_key2())
  #   send_tokens(public_key3, public_key1, 1, Keys.get_private_key3())
  #
  #   :timer.sleep(3000)
  #   send_token_test(counter-1)
  # end
end
