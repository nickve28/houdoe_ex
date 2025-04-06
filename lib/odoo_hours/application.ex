defmodule OdooHours.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Workaround for Windows DNS resolver
    if match?({:win32, _}, :os.type()) do
      :inet_db.set_lookup([:native, :dns])

      System.get_env("ODOO_WINDOWS_ERL_DNS_SERVER")
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      |> :inet_db.add_ns()
    end

    children = [
      OdooHoursWeb.Telemetry,
      OdooHours.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:odoo_hours, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:odoo_hours, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OdooHours.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: OdooHours.Finch},
      # Start a worker by calling: OdooHours.Worker.start_link(arg)
      # {OdooHours.Worker, arg},
      # Start to serve requests, typically the last entry
      OdooHoursWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OdooHours.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OdooHoursWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
