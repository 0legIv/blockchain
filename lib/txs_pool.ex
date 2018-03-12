defmodule Blockchain.TxsPool do

  alias Blockchain.Structures.Tx

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_tx(tx) do
    GenServer.call(__MODULE__, {:add_tx, tx})
  end

  def get_pool() do
    GenServer.call(__MODULE__, {:get_pool})
  end

  #server

  def handle_call({:add_tx, tx}, _, state) do
    {:reply, :ok, [state | tx]}
  end

  def handle_call({:get_pool}, _, state) do
    {:reply, state, state}
  end


end
