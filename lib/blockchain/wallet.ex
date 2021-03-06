defmodule Blockchain.Wallet do
  alias Blockchain.Chain
  alias Blockchain.Structures.Tx
  alias Blockchain.TxsPool
  alias Blockchain.Keys

  @spec check_amount(String.t()) :: integer
  def check_amount(public_key) do
    chain = Chain.get_state()
    txs_list = for tx <- chain, do: tx.txs_list

    Enum.reduce(List.flatten(txs_list), 0, fn tx, acc ->
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
  @spec send_tokens(String.t(), String.t(), integer, String.t()) :: Tuple.t()
  def send_tokens(from_acc, to_acc, amount, private_key) do
    # creates the transaction
    tx = Tx.create_tx(from_acc, to_acc, amount)

    if tx != {:error, :wrong_tx} do
      # signs the tx with private key
      signed_tx = Tx.sign_data(tx, private_key)
      # add tx to the pool
      TxsPool.add_tx(signed_tx)
    else
      tx
    end
  end
end
