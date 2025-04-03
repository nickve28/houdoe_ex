defmodule OdooHoursWeb.PageController do
  use OdooHoursWeb, :controller

  @url System.get_env("ODOO_URL")
  @database System.get_env("ODOO_DB")


  def home(conn, _params) do
    external_id = conn
    |> get_session(:external_id)

    password = conn
    |> get_session(:password)

    config = %OdooHours.Client{database: @database, url: @url}

    OdooHours.Client.user_entries(
      config,
      external_id,
      password
    )

    render(conn, :home, layout: false, external_id: external_id)
  end
end
