defmodule OdooHoursWeb.Live.HoursLive do
  use OdooHoursWeb, :live_view

  def mount(_params, session, socket) do
    %{"external_id" => external_id, "password" => password} = session
    config = %OdooHours.Client{database: odoo_db(), url: odoo_url()}

    start_of_week =
      Date.utc_today()
      |> Date.beginning_of_week(:monday)

    end_of_week = start_of_week |> Date.add(4)

    day_range =
      Date.range(
        end_of_week,
        start_of_week
      )

    hours =
      OdooHours.Client.user_entries(
        config,
        external_id,
        password,
        where: [] |> filter_current_week(start_of_week, end_of_week)
      )

    socket =
      socket
      |> stream(:hours, hours, at: 0)
      |> assign(:day_range, day_range |> Enum.to_list() |> IO.inspect)

    {:ok, socket}
  end

  defp filter_current_week(filters, start_of_week, end_of_week) do
    [
      ["date", ">=", start_of_week |> Date.to_string()],
      ["date", "<=", end_of_week |> Date.to_string()]
      | filters
    ]
  end

  defp odoo_url, do: System.get_env("ODOO_URL")
  defp odoo_db, do: System.get_env("ODOO_DB")
end
