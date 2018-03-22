defmodule Blockchain.Chain do
  alias Blockchain.Structures.Block

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [Block.genesis_block()], name: __MODULE__)
  end

  def empty_chain_state() do
    GenServer.call(__MODULE__, {:empty_chain_state})
  end

  def get_state() do
    GenServer.call(__MODULE__, {:get_state})
  end

  def latest_block() do
    GenServer.call(__MODULE__, {:latest_block})
  end

  def latest_block_hash() do
    GenServer.call(__MODULE__, {:latest_block_hash})
  end

  @spec add_block(%Block{}) :: :ok
  def add_block(block) do
    GenServer.call(__MODULE__, {:add_block, block})
  end

  # server

  def handle_call({:get_state}, _, state) do
    {:reply, state, state}
  end

  def handle_call({:empty_chain_state}, _, state) do
    {:reply, :ok, [Block.genesis_block()]}
  end

  def handle_call({:latest_block}, _, state) do
    latest_block = List.last(state)
    {:reply, latest_block, state}
  end

  def handle_call({:latest_block_hash}, _, state) do
    latest_block = List.last(state)
    latest_block = Block.hash_block(latest_block)

    {:reply, latest_block, state}
  end

  def handle_call({:add_block, block}, _, state) do
    {:reply, :ok, state ++ [block]}
  end
end
