defmodule OdooHoursWeb.AuthenticationController do
  use OdooHoursWeb, :controller

  def login(conn, _params) do
    changeset = Authentication.changeset(%Authentication{})
    render(conn, :login, layout: false, changeset: changeset)
  end

  def authenticate(conn, params) do
    changeset = Authentication.changeset(%Authentication{}, Map.get(params, "authentication"))
    # IO.puts(changeset.username)
    auth = Map.get(params, "authentication")
    %{ "username" => username, "password" => password } = auth
    config = %OdooHours.Client{database: odoo_url(), url: odoo_db()}

    {:ok, id} = OdooHours.Client.authenticate(
      config, username, password
    )

    conn
    |> put_session(:external_id, id)
    |> put_session(:password, password)
    |> redirect(to: ~p"/hours")
  end


  defp odoo_url, do: System.get_env("ODOO_URL")
  defp odoo_db, do: System.get_env("ODOO_DB")
end
