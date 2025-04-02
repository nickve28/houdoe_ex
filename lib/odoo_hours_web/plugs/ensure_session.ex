defmodule OdooHoursWeb.Plugs.EnsureSession do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :external_id) do
      nil ->
        conn
        # todo can use paths here i think
        |> redirect(to: "/authentication/login")
      _session -> conn
    end
  end
end
