defmodule Blockchain.Structures.Tx do
  alias Blockchain.Structures.Tx
  alias Blockchain.TxsPool
  alias Blockchain.Keys

  defstruct [
    :id,
    :from_acc,
    :to_acc,
    :amount,
    :el_curve_sign
  ]

  @type t :: %Tx{
          id: string(),
          from_acc: string(),
          to_acc: string(),
          amount: integer,
          el_curve_sign: string()
        }

  def create_tx(from_acc, to_acc, amount) do
    if String.length(to_acc) > 5 && amount > 0 && is_integer(amount) do
      new_tx = %Tx{
        id: generate_tx_id(),
        from_acc: from_acc,
        to_acc: to_acc,
        amount: amount,
        el_curve_sign: ""
      }
    else
      {:error, :wrong_tx}
    end
  end

  @doc """
    Coinbase tx, gives 25 tokens to account. From acc is empty
  """
  def coinbase_tx(to_acc) do
    Tx.create_tx("", to_acc, 25)
  end

  def sign_data(tx, private_key) do
    {:ok, private_key} = Base.decode16(private_key)
    data = hash_tx(tx)
    sign = :crypto.sign(:ecdsa, :sha256, data, [private_key, :secp256k1]) |> Base.encode16()
    %{tx | el_curve_sign: sign}
  end

  @doc """
    Verify the transaction with the public key.
  """
  def is_verified?(tx_hash, signature, pub_key) do
    if pub_key == "" do
      true
    else
      {:ok, pub_key} = Base.decode16(pub_key)
      {:ok, signature} = Base.decode16(signature)
      :crypto.verify(:ecdsa, :sha256, tx_hash, signature, [pub_key, :secp256k1])
    end
  end

  @doc """
    First coinbase transactions in the genesis block. They give 25 tokens to every
    account.
  """
  def genesis_block_txs() do
    tx1 = Keys.get_private_key1() |> Keys.generate_public_key() |> coinbase_tx()
    tx2 = Keys.get_private_key2() |> Keys.generate_public_key() |> coinbase_tx()
    tx3 = Keys.get_private_key3() |> Keys.generate_public_key() |> coinbase_tx()
    tx4 = Keys.get_miner_private_key() |> Keys.generate_public_key() |> coinbase_tx()
    [tx1, tx2, tx3, tx4]
  end

  def generate_tx_id() do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end

  @spec hash_tx(String.t()) :: String.t()
  def hash_tx(tx) do
    data = tx.id <> tx.from_acc <> tx.to_acc <> to_string(tx.amount)
    :crypto.hash(:sha256, data) |> Base.encode16()
  end

  @spec hash_txs(List.t()) :: List.t()
  def hash_txs(txs) do
    hashed_txs = for tx <- txs, do: hash_tx(tx)
  end
end
