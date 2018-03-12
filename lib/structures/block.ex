defmodule Blockchain.Structures.Block do

  alias Blockchain.Structures.Header
  alias Blockchain.Structures.Tx
  alias Blockchain.Structures.Block

  defstruct [
    :header,
    :txs_list
  ]

  @type t :: %Block{
    header: Header.t,
    txs_list: list(Tx.t)
  }

  def genesis_block() do
    %Block{
      header: Header.genesis_header,
      txs_list: []
    }
  end

  def hash_block(block) do

  end


end
