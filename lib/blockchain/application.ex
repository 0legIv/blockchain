defmodule Blockchain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # List all child processes to be supervised
    mongo_opts = Application.fetch_env!(:blockchain, :mongo)

    children = [
      BlockchainWeb.Endpoint,
      worker(Mongo, [mongo_opts], id: :mongo),
      Blockchain.TxsPool,
      Blockchain.Chain,
      Blockchain.Miner
      # Starts a worker by calling: Blockchain.Worker.start_link(arg)
      # {Blockchain.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blockchain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BlockchainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
