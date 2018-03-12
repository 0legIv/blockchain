defmodule Blockchain.Structures.Header do

  alias Blockchain.Structures.Header

  defstruct [
    :prev_block,
    :diff_target,
    :nonce,
    :chain_state_merkle,
    :txs_merkle
  ]

  @type t :: %Header{
    prev_block: binary(),
    diff_target: integer,
    nonce: integer,
    chain_state_merkle: binary(),
    txs_merkle: binary()
  }

  def create_hd(prev_block, diff_target, nonce, chain_state_merkle, txs_merkle) do
    %Header{
      prev_block: prev_block,
      diff_target: diff_target,
      nonce: nonce,
      chain_state_merkle: chain_state_merkle,
      txs_merkle: txs_merkle
    }
  end

  def genesis_header() do
    %Header{
      prev_block: <<0::256>>,
      diff_target: 1,
      nonce: 222,
      chain_state_merkle: <<0::256>>,
      txs_merkle: <<0::256>>
    }
  end

end
