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

  def create_block(header, txs_list) do
    %Block{
      header: header,
      txs_list: txs_list
    }
  end

  def genesis_block() do
    %Block{
      header: Header.genesis_header,
      txs_list: Tx.genesis_block_txs()
    }
  end

  def hash_block(block) do
    # hashed_txs = for tx <- block.txs_list, do: Tx.hash_tx(tx)
    Header.hash_header(block.header)
  end


end
