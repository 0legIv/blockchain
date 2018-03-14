defmodule Blockchain.Wallet do

  alias Blockchain.Chain
  alias Blockchain.Structures.Tx
  alias Blockchain.TxsPool

  @miner_private_key "09572E1A9FB5DECE6DA88DE0EE009849"
  @miner_public_key "04E891784A12EB25E93F0F2A9D74C8AB4A9AD3C5FBF3C84C269EFBFDF78B870DD9DCDCB73EC68D6A17762E3AE778C826E5E90A5A409C3C56C6AAA25A33925A5EA5"

  @public_key "04D598B4A5D8924BA1A1358A0C421F15F328B73640854E4AFA607549C1933CBBDBBC7AF7EF88D4B0F4B50F64390AC38CC83C364CD6C99DD84EEDFB5DBCAC6F4AE6"

  def check_amount(public_key) do
    chain = Chain.get_chainstate()
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

  def send_tokens(from_acc, to_acc, amount, private_key) do
    tx = Tx.create_tx(from_acc, to_acc, amount)
    signed_tx = Tx.sign_data(tx, private_key)
    TxsPool.add_tx(signed_tx)
  end

end
