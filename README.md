# Blockchain

Simple blockchain implementation in Elixir. For proof of work "hashcash" algorithm is used.

**To run:** iex -S mix

**Start the miner:** Blockchain.Miner.start_mining()

**Stop the miner:** Blockchain.Miner.stop_mining()

**Check the chainstate:** Blockchain.Chain.get_state()

**To test the wallet functionality**: Blockchain.Wallet.send_token_test()
  This is the test simulation of 4 hardcoded accounts, sending tokens to each other.
  The result of txs you can see when you check the **Chainstate**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `blockchain` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:blockchain, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/blockchain](https://hexdocs.pm/blockchain).
