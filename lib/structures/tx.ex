defmodule Blockchain.Structures.Tx do

  alias Blockchain.Structures.Tx
  alias Blockchain.TxsPool

  defstruct [
    :from_acc,
    :to_acc,
    :amount,
    :el_curve_sign
  ]

  @type t :: %Tx{
    from_acc: string(),
    to_acc: string(),
    amount: integer,
    el_curve_sign: string()
  }

  def create_tx(from_acc, to_acc, amount, el_curve_sign) do
    new_tx = %Tx{
      from_acc: from_acc,
      to_acc: to_acc,
      amount: amount,
      el_curve_sign: el_curve_sign
    }
  #  TxsPool.add_tx(new_tx)
  end

  def hash_tx(tx) do
    data = tx.from_acc <> tx.to_acc <> tx.el_curve_sign
    :crypto.hash(:sha256, data)
  end

end
