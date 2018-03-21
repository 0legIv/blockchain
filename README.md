# Blockchain

Simple blockchain implementation in Elixir. For proof of work "hashcash" algorithm is used.

**To run:** iex -S mix

**Start the miner:** Blockchain.Miner.start_mining()

**Stop the miner:** Blockchain.Miner.stop_mining()

**Check the chainstate:** Blockchain.Chain.get_state()

**To check the wallet amount**: Blockchain.Wallet.check_amount(public_key)

**To send tokens**: Blockchain.Wallet.send_tokens(sender_pub_key, receiver_pub_key, amount, sender_private_key)



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
