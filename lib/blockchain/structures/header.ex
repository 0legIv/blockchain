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

  @spec create_hd(String.t(), String.t(), integer, String.t(), String.t()) :: %Header{}
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
      prev_block: "",
      diff_target: 1,
      nonce: 222,
      chain_state_merkle: "",
      txs_merkle: ""
    }
  end

  def hash_header(header) do
    data = header.prev_block <> to_string(header.nonce) <> header.txs_merkle
    :crypto.hash(:sha256, data) |> Base.encode16()
  end
end
