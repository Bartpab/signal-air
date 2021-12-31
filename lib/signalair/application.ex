defmodule SignalAir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # SignalAir.Repo.Ecto,
      # Start the memory repository
      SignalAir.Repo.Memoire,
      # Start the Telemetry supervisor
      SignalAirWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SignalAir.PubSub},
      # Start the Endpoint (http/https)
      SignalAirWeb.Endpoint
      # Start a worker by calling: SignalAir.Worker.start_link(arg)
      # {SignalAir.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SignalAir.Supervisor]
    Supervisor.start_link(children, opts)

  end

  @impl true
  def stop(_state) do
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SignalAirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
