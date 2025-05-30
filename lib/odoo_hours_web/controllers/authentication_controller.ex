defmodule OdooHoursWeb.AuthenticationController do
  use OdooHoursWeb, :controller

  @url System.get_env("ODOO_URL")
  @database System.get_env("ODOO_DB")

  def login(conn, _params) do
    changeset = Authentication.changeset(%Authentication{})
    render(conn, :login, layout: false, changeset: changeset)
  end

  def authenticate(conn, params) do
    changeset = Authentication.changeset(%Authentication{}, Map.get(params, "authentication"))
    # IO.puts(changeset.username)
    auth = Map.get(params, "authentication")
    %{ "username" => username, "password" => password } = auth
    config = %OdooHours.Client{database: @database, url: @url}

    {:ok, id} = OdooHours.Client.authenticate(
      config, username, password
    )

    conn
    |> put_session(:external_id, id)
    |> put_session(:password, password)
    |> redirect(to: "/")
  end
end
