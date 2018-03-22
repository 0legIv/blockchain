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

  @difficulty 5

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args) do
    state = %{
      miner: :stopped
    }

    {:ok, state}
  end

  def stop_mining() do
    GenServer.call(__MODULE__, {:stop_mining}, 12000)
  end

  def start_mining() do
    GenServer.call(__MODULE__, {:start_mining})
  end

  def get_state() do
    GenServer.call(__MODULE__, {:get_state})
  end

  # server

  def handle_call({:start_mining}, _from, %{miner: :running} = state) do
    {:reply, :already_started, state}
  end

  def handle_call({:start_mining}, _from, state) do
    state = %{state | miner: :running}
    Process.send(self(), :work, [:noconnect])
    {:reply, :ok, state}
  end

  def handle_call({:stop_mining}, _from, %{miner: :stopped} = state) do
    {:reply, :already_stopped, state}
  end

  def handle_call({:stop_mining}, _from, state) do
    {:reply, :ok, %{state | miner: :stopped}}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:work, state) do
    mining(state)
    {:noreply, state}
  end

  @doc """
    Verifies the transactions from the Txs pool.
  """
  def check_txs(txs) do
    verified_txs =
      Enum.reduce(txs, [], fn tx, valid_txs ->
        if Tx.is_verified?(Tx.hash_tx(tx), tx.el_curve_sign, tx.from_acc) and
             tx.amount <=
               Wallet.check_amount(tx.from_acc) |> check_amount_after_txs(valid_txs, tx.from_acc) do
          valid_txs ++ [tx]
        else
          valid_txs
        end
      end)

    verified_txs ++ [Tx.coinbase_tx(Keys.get_miner_public_key())]
  end

  @doc """
    Checks the amount of wallet after the verified tx, in order to exclude double spend tx
  """
  def check_amount_after_txs(amount, txs, public_key) do
    Enum.reduce(txs, amount, fn tx, acc ->
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
    Mining algorithm
  """
  defp mining(%{miner: :running} = state) do
    # validate txs
    valid_txs = TxsPool.get_and_empty_pool() |> check_txs()
    # create merkle tree from valid txs and return the root
    merkle_root = MerkleTree.get_merkle_root(Tx.hash_txs(valid_txs))
    prev_block_hash = Chain.latest_block_hash()
    # create merkle tree from the blocks that are already created
    chain_state_merkle = Chain.get_state() |> Block.hash_blocks() |> MerkleTree.get_merkle_root()
    # create header with nonce 1
    hd = Header.create_hd(prev_block_hash, @difficulty, 1, chain_state_merkle, merkle_root)
    # start the proof of work function
    pow = proof_of_work(hd)
    # add new block to the chainstate
    new_block_to_chainstate(pow, valid_txs)
    # call again the function mining()
    Process.send_after(self(), :work, 2000)
  end

  defp mining(%{miner: :stopped} = state) do
    state
  end

  def mine_single_block() do
    # validate txs
    valid_txs = TxsPool.get_and_empty_pool() |> check_txs()
    # create merkle tree from valid txs and return the root
    merkle_root = MerkleTree.get_merkle_root(Tx.hash_txs(valid_txs))
    prev_block_hash = Chain.latest_block_hash()
    # create merkle tree from the blocks that are already created
    chain_state_merkle = Chain.get_state() |> Block.hash_blocks() |> MerkleTree.get_merkle_root()
    # create header with nonce 1
    hd = Header.create_hd(prev_block_hash, @difficulty, 1, chain_state_merkle, merkle_root)
    # start the proof of work function
    pow = proof_of_work(hd)
    # add new block to the chainstate
    new_block_to_chainstate(pow, valid_txs)
  end

  @doc """
    Proof of work algorithm
  """
  defp proof_of_work(hd) do
    # hash the header
    hash = Header.hash_header(hd)
    # check if target of 0 in the beginning is matched
    if Regex.match?(~r/^[0]{#{hd.diff_target}}.*$/, hash) do
      hd
    else
      # increase nonce if target is not matched
      proof_of_work(%{hd | nonce: hd.nonce + 1})
    end
  end

  defp new_block_to_chainstate(hd, txs) do
    bl = Block.create_block(hd, txs)
    Chain.add_block(bl)
  end
end
