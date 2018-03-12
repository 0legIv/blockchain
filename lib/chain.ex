defmodule Blockchain.Chain do

  alias Blockchain.Structures.Block

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [Block.genesis_block], name: __MODULE__)
  end

  def get_chainstate() do
    GenServer.call(__MODULE__, {:get_state})
  end

  def latest_block_hash() do
    GenServer.call(__MODULE__, {:latest_block_hash})
  end

  def add_block(block) do
    GenServer.call(__MODULE__, {:add_block, block})
  end

  #server

  def handle_call({:get_state}, _, state) do
    {:reply, state, state}
  end

  def handle_call({:latest_block_hash}, _, state) do
    last_block = List.last(state)

    {:reply, List.last(state), state}
  end

  def handle_call({:add_block, block}, _, state) do
    {:reply, :ok, [state | block]}
  end

end
