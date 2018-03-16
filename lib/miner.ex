defmodule Blockchain.Miner do
  use GenServer

  alias Blockchain.TxsPool
  alias Blockchain.Chain
  alias Blockchain.Wallet
  alias Blockchain.Keys
  alias Blockchain.Structures.Tx
  alias Blockchain.Structures.Header
  alias Blockchain.Structures.Block
  alias Blockchain.MerkleTree

  def start_link(_args) do
    GenServer.start_link(__MODULE__,  %{}, name: __MODULE__)
  end

  def init(state) do
    state = %{
      memory_pool: []
    }
    start_mining()
    {:ok, state}
  end

  def start_mining() do
    GenServer.cast(__MODULE__, {:start_mining})
  end

  def get_state() do
    GenServer.call(__MODULE__, {:get_state})
  end

  #server

  def handle_cast({:start_mining}, state) do
    mining(state)
    {:reply, :ok, state}
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
      valid_txs ++ [Tx.coinbase_tx(Keys.get_miner_public_key)]
  end

  defp mining(state) do
    txs = TxsPool.get_and_empty_pool()
    state = %{state | memory_pool: check_txs(txs)}
    merkle_root = MerkleTree.get_merkle_root(Tx.hash_txs(state.memory_pool))
    prev_block_hash = Chain.latest_block_hash
    hd = Header.create_hd(prev_block_hash, 5, 1, "", merkle_root)
    pow = proof_of_work(hd)
    new_block_to_chainstate(pow, state.memory_pool)
    mining(state)
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
