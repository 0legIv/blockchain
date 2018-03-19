defmodule Blockchain.Wallet do

  alias Blockchain.Chain
  alias Blockchain.Structures.Tx
  alias Blockchain.TxsPool
  alias Blockchain.Keys

  @spec check_amount(String.t) :: integer
  def check_amount(public_key) do
    chain = Chain.get_state()
    txs_list = for tx <- chain, do: tx.txs_list
    Enum.reduce(List.flatten(txs_list), 0,
      fn(tx, acc) ->
        cond do
          tx.to_acc == public_key ->
            acc + tx.amount
          tx.from_acc == public_key ->
            acc - tx.amount
          true ->
            acc
        end
      end)
  end

  @doc """
    Send tokens to the account
  """
  @spec send_tokens(String.t, String.t, integer, String.t) :: Tuple.t
  def send_tokens(from_acc, to_acc, amount, private_key) do
    tx = Tx.create_tx(from_acc, to_acc, amount) # creates the transaction
    signed_tx = Tx.sign_data(tx, private_key)  # signs the tx with private key
    TxsPool.add_tx(signed_tx) # add tx to the pool
  end

  def send_token_test() do
    entropy_byte_size = 16
    public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
    public_key2 = Keys.get_private_key2() |> Keys.generate_public_key()
    public_key3 = Keys.get_private_key3() |> Keys.generate_public_key()
    send_tokens(Keys.get_miner_public_key, public_key1, 5, Keys.get_miner_private_key)
    send_tokens(public_key1, public_key2, 3, Keys.get_private_key1())
    send_tokens(public_key2, public_key3, 2, Keys.get_private_key2())
    send_tokens(public_key3, public_key1, 1, Keys.get_private_key3())
  end
end
