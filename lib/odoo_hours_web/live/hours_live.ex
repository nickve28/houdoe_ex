defmodule OdooHoursWeb.Live.HoursLive do
  use OdooHoursWeb, :live_view

  @url System.get_env("ODOO_URL")
  @database System.get_env("ODOO_DB")


  def mount(_params, session, socket) do
    %{ "external_id" => external_id, "password" => password } = session
    config = %OdooHours.Client{database: @database, url: @url}
    today = Date.utc_today

    hours = OdooHours.Client.user_entries(
      config,
      external_id,
      password,
      where: [
        ["date", ">=", Date.add(today, -7) |> Date.to_string],
        ["date", "<=", today |> Date.to_string]
      ]
    )


    socket = socket
      |> stream(:hours, hours, at: 0)
    {:ok, socket}
  end
end
