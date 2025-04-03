defmodule OdooHoursWeb.PageController do
  use OdooHoursWeb, :controller

  def home(conn, _params) do
    external_id = conn
    |> get_session(:external_id)

    render(conn, :home, layout: false, external_id: external_id)
  end
end
