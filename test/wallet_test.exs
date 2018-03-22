defmodule WalletTest do
  use ExUnit.Case

  alias Blockchain
  alias Blockchain.Miner
  alias Blockchain.Wallet
  alias Blockchain.Keys
  alias Blockchain.Chain

  test "check_amount_after_transaction" do
    Chain.empty_chain_state()
    # initial amount = 25
    public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
    # initial amount = 25
    public_key2 = Keys.get_private_key2() |> Keys.generate_public_key()
    Wallet.send_tokens(public_key1, public_key2, 15, Keys.get_private_key1())
    Miner.mine_single_block()
    assert Wallet.check_amount(public_key2) == 40
    assert Wallet.check_amount(public_key1) == 10
  end

  test "send_invalid_value_of_tokens" do
    Chain.empty_chain_state()
    # initial amount = 25
    public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
    # initial amount = 25
    public_key2 = Keys.get_private_key2() |> Keys.generate_public_key()
    Wallet.send_tokens(public_key1, public_key2, 15.23, Keys.get_private_key1())
    Miner.mine_single_block()
    # hasn't been changed
    assert Wallet.check_amount(public_key1) == 25
    # hasn't been changed
    assert Wallet.check_amount(public_key2) == 25
  end

  test "send_tokens_more_than_amount" do
    Chain.empty_chain_state()
    # initial amount = 25
    public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
    # initial amount = 25
    public_key2 = Keys.get_private_key2() |> Keys.generate_public_key()
    # sent 20 tokens
    Wallet.send_tokens(public_key1, public_key2, 20, Keys.get_private_key1())
    # sent again 20 tokens
    Wallet.send_tokens(public_key1, public_key2, 20, Keys.get_private_key1())
    # 2 txs added in the same block
    Miner.mine_single_block()
    # sent only 20 tokens
    assert Wallet.check_amount(public_key1) == 5
    # get only 20 tokens
    assert Wallet.check_amount(public_key2) == 45
  end
end
