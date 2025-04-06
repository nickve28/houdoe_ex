defmodule OdooHoursWeb.Live.HoursLive do
  use OdooHoursWeb, :live_view

  def mount(_params, session, socket) do
    %{"external_id" => external_id, "password" => password} = session
    config = %OdooHours.Client{database: odoo_db(), url: odoo_url()}

    hours =
      OdooHours.Client.user_entries(
        config,
        external_id,
        password,
        where: [] |> filter_current_week()
      )

    day_range =
      hours
      |> Enum.map(fn %{date: date} -> date end)
      |> Enum.uniq()
      |> Enum.sort(fn x, y -> Date.before?(y, x) end)

    socket =
      socket
      |> stream(:hours, hours, at: 0)
      |> assign(:day_range, day_range)

    {:ok, socket}
  end

  defp filter_current_week(filters) do
    today = Date.utc_today()

    [
      ["date", ">=", Date.add(today, -7) |> Date.to_string()],
      ["date", "<=", today |> Date.to_string()]
      | filters
    ]
  end

  defp odoo_url, do: System.get_env("ODOO_URL")
  defp odoo_db, do: System.get_env("ODOO_DB")
end
