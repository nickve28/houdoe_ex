defmodule OdooHoursWeb.Plugs.EnsureSession do
  @moduledoc """
  A plug that checks whether the external_id has been set
  which is returned from odoo
  If not, redirects to the login page
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
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
