defmodule OdooHoursWeb.PageController do
  use OdooHoursWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    changeset = Authentication.changeset(%Authentication{})
    render(conn, :home, layout: false, changeset: changeset)
  end
end
