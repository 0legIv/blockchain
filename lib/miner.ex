defmodule Blockchain.Miner do
  use GenServer

  alias Blockchain.TxsPool
  alias Blockchain.Chain
  alias Blockchain.Wallet
  alias Blockchain.Keys
  alias Blockchain.Structures.Tx
  alias Blockchain.Structures.Header
  alias Blockchain.Structures.Block

  def start_link(_args) do
    GenServer.start_link(__MODULE__,  %{}, name: __MODULE__)
  end

  def init(state) do
    state = %{
      memory_pool: []
    }
    {:ok, state}
  end

  def start_mining() do
    GenServer.call(__MODULE__, {:start_mining})
  end

  def get_txs() do
    GenServer.call(__MODULE__, {:get_txs})
  end

  def get_state() do
    GenServer.call(__MODULE__, {:get_state})
  end

  #server

  def handle_call({:start_mining}, _, state) do
    txs_hash = Tx.hash_txs(state.memory_pool)
    prev_block_hash = Chain.latest_block_hash
    hd = Header.create_hd(prev_block_hash, 4, 1, "", txs_hash)
    pow = proof_of_work(hd)
    new_block_to_chainstate(pow, state.memory_pool)
    {:reply, :ok, state}
  end

  def handle_call({:get_txs}, _, state) do
    txs = TxsPool.get_and_empty_pool()
    {:reply, :ok, %{state | memory_pool: check_txs(txs)}}
  end

  def handle_call({:get_state}, _, state) do
    {:reply, state, state}
  end

  defp check_txs(txs) do
    valid_txs = for tx <- txs,
      Tx.is_verified?(Tx.hash_tx(tx), tx.el_curve_sign, tx.from_acc),
      # String.length(tx.from_acc) > 10,
      # String.length(tx.to_acc) > 10,
      tx.amount < Wallet.check_amount(tx.from_acc),
      # String.length(tx.el_curve_sign) > 10,
      do: tx
      valid_txs ++ [Tx.coinbase_tx("04E891784A12EB25E93F0F2A9D74C8AB4A9AD3C5FBF3C84C269EFBFDF78B870DD9DCDCB73EC68D6A17762E3AE778C826E5E90A5A409C3C56C6AAA25A33925A5EA5")]
  end

  defp proof_of_work(hd) do
    hash = Header.hash_header(hd)
    if Regex.match?(~r/^[0]{#{hd.diff_target}}.*$/, hash) do
      hd
    else
      proof_of_work(%{hd | nonce: hd.nonce + 1})
    end
  end

  defp new_block_to_chainstate(hd, txs) do
    bl = Block.create_block(hd, txs)
    Chain.add_block(bl)
  end

end
