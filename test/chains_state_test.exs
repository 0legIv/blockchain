defmodule ChainStateTest do
    use ExUnit.Case
  
    alias Blockchain
    alias Blockchain.Structures.Tx
    alias Blockchain.Structures.Block
    alias Blockchain.Miner
    alias Blockchain.Wallet
    alias Blockchain.Keys
    alias Blockchain.Chain
    alias Blockchain.TxsPool
    alias Blockchain.MerkleTree

    test "block_added_to_chainstate" do
        Chain.empty_chain_state()
        state = Chain.get_state |> Block.hash_blocks
        Miner.mine_single_block()
        latest_block = Chain.latest_block
        assert latest_block.header.chain_state_merkle == MerkleTree.get_merkle_root(state)
    end

    test "tx_added_to_chainstate" do
        Chain.empty_chain_state()
        public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
        Wallet.send_tokens(Keys.get_miner_public_key, public_key1, 5, Keys.get_miner_private_key)
        [tx] = TxsPool.get_pool()
        Miner.mine_single_block()
        ch_state = Chain.get_state
        txs = for bl <- ch_state, do: bl.txs_list 
        hashed_txs = Tx.hash_txs(List.flatten(txs))
        hashed_tx = Tx.hash_tx(tx)
        assert Enum.member?(hashed_txs, hashed_tx)
    end

    test "tx_not_added_to_chainstate" do
        Chain.empty_chain_state()
        public_key1 = Keys.get_private_key1() |> Keys.generate_public_key()
        Wallet.send_tokens(Keys.get_miner_public_key, public_key1, 125, Keys.get_miner_private_key)
        [tx] = TxsPool.get_pool()
        Miner.mine_single_block()
        ch_state = Chain.get_state
        txs = for bl <- ch_state, do: bl.txs_list 
        hashed_txs = Tx.hash_txs(List.flatten(txs))
        hashed_tx = Tx.hash_tx(tx)
        refute Enum.member?(hashed_txs, hashed_tx)
    end

end