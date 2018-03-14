defmodule Blockchain.Structures.Tx do

  @private_key1 "F98B04BC42B472ACC18829FAA979FBA3"
  @private_key2 "7DE02990657F7DA9A0F7008957461A59"
  @private_key3 "10CAA0396F838C7C4F58575B459C42FD"
  @miner_private_key "09572E1A9FB5DECE6DA88DE0EE009849"

  alias Blockchain.Structures.Tx
  alias Blockchain.TxsPool
  alias Blockchain.Keys

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

  def create_tx(from_acc, to_acc, amount) do
    new_tx = %Tx{
      from_acc: from_acc,
      to_acc: to_acc,
      amount: amount,
      el_curve_sign: ""
    }
  end

  def coinbase_tx(to_acc) do
    Tx.create_tx("", to_acc, 25)
  end

  def sign_data(tx, private_key) do
    {:ok, private_key} = Base.decode16(private_key)
    data = hash_tx(tx)
    sign = :crypto.sign(:ecdsa, :sha256, data, [private_key, :secp256k1]) |> Base.encode16()
    %{tx | el_curve_sign: sign}
  end

  def is_verified?(data, signature, pub_key) do
    # {:ok, data} = Base.decode16(data)
    if(pub_key == "") do
      true
    else
      {:ok, pub_key} = Base.decode16(pub_key)
      {:ok, signature} = Base.decode16(signature)
      :crypto.verify(:ecdsa, :sha256, data, signature, [pub_key, :secp256k1])
    end
  end

  def genesis_block_txs() do
    tx1 = coinbase_tx(Keys.generate_public_key(@private_key1))
    tx2 = coinbase_tx(Keys.generate_public_key(@private_key2))
    tx3 = coinbase_tx(Keys.generate_public_key(@private_key3))
    tx4 = coinbase_tx(Keys.generate_public_key(@miner_private_key))
    [tx1, tx2, tx3, tx4]
  end

  def hash_tx(tx) do
    data = tx.from_acc <> tx.to_acc <> to_string(tx.amount)
    :crypto.hash(:sha256, data) |> Base.encode16
  end

  def hash_txs(txs) do
    hashed_txs = for tx <- txs, do: hash_tx(tx)
    Enum.join hashed_txs
  end

end
