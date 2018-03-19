defmodule TxsTest do
  use ExUnit.Case

  alias Blockchain
  alias Blockchain.Structures.Tx

  test "add valid tx" do
    tx = Tx.create_tx("asdddd", "aaaaasdf", 1)
    assert tx != {:error, :wrong_tx} 
  end

  test "add invalid tx" do
    assert Tx.create_tx("asdddd", "aaaaasdf", -1) == {:error, :wrong_tx}
  end
end
