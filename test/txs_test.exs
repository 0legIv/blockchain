defmodule TxsTest do
  use ExUnit.Case

  alias Blockchain
  alias Blockchain.Structures.Tx
  alias Blockchain.Miner
  alias Blockchain.Wallet
  alias Blockchain.Keys
  alias Blockchain.Chain

  test "add valid tx" do
    tx = Tx.create_tx("asdddd", "aaaaasdf", 1)
    assert tx == %Tx{
        id: tx.id,
        from_acc: "asdddd",
        to_acc: "aaaaasdf",
        amount: 1,
        el_curve_sign: ""
      }
  end

  test "add invalid tx" do
    assert Tx.create_tx("asdddd", "aaaaasdf", -1) == {:error, :wrong_tx}
  end

  test "send_tokens_with_correct_sign" do
    Chain.empty_chain_state()
    public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
    Wallet.send_tokens(Keys.get_miner_public_key, public_key1, 15, Keys.get_miner_private_key)
    Miner.mine_single_block()
    chain_txs = for x <- Chain.get_state, do: x.txs_list
    filtered_tx = for bl <- List.flatten(chain_txs),
     bl.from_acc == Keys.get_miner_public_key,
     bl.to_acc == public_key1,
     do: bl.id

    assert filtered_tx != []
 end

 test "send_tokens_with_wrong_sign" do
   Chain.empty_chain_state() 
   public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
   Wallet.send_tokens(Keys.get_miner_public_key, public_key1, 5, Keys.get_private_key1) # different private key, so sign for tx will be invalid
   Miner.mine_single_block()
   chain_txs = for x <- Chain.get_state, do: x.txs_list
   filtered_tx = for tx <- List.flatten(chain_txs),
    tx.from_acc == Keys.get_miner_public_key,
    tx.to_acc == public_key1,
    do: tx.id

   assert filtered_tx == []
 end

end
