defmodule SendTokensTest do
  use ExUnit.Case

  alias Blockchain
  alias Blockchain.Structures.Tx
  alias Blockchain.Miner
  alias Blockchain.Wallet
  alias Blockchain.Keys



  test "send_tokens" do
    entropy_byte_size = 16
     public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
     public_key2 = Keys.get_private_key2() |> Keys.generate_public_key()
     public_key3 = Keys.get_private_key3() |> Keys.generate_public_key()
     Wallet.send_tokens(Keys.get_miner_public_key, public_key1, 5, Keys.get_miner_private_key)
     Wallet.send_tokens(public_key1, public_key2, 3, Keys.get_private_key1())
     Wallet.send_tokens(public_key2, public_key3, 2, Keys.get_private_key2())
     Wallet.send_tokens(public_key3, public_key1, 1, Keys.get_private_key3())
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
