defmodule OdooHoursWeb.Live.HoursLive do
  use OdooHoursWeb, :live_view

  @url System.get_env("ODOO_URL")
  @database System.get_env("ODOO_DB")


  def mount(_params, session, socket) do
    %{ "external_id" => external_id, "password" => password } = session
    config = %OdooHours.Client{database: @database, url: @url}

    hours = OdooHours.Client.user_entries(
      config,
      external_id,
      password,
      where: [] |> filter_current_week()
    )

    day_range = hours |> Enum.map(fn %{ date: date} -> date end) |> Enum.uniq |> Enum.sort(fn x, y -> Date.before?(y, x) end)

    socket = socket
      |> stream(:hours, hours, at: 0)
      |> assign(:day_range, day_range)
    {:ok, socket}
  end

  defp filter_current_week(filters) do
    today = Date.utc_today

    [
      ["date", ">=", Date.add(today, -7) |> Date.to_string],
      ["date", "<=", today |> Date.to_string]
      | filters
    ]
  end
end
