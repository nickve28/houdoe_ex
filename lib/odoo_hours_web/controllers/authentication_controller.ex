defmodule OdooHoursWeb.AuthenticationController do
  use OdooHoursWeb, :controller

  @url System.get_env("ODOO_URL")
  @path "#{@url}/xmlrpc/2/common"
  @database System.get_env("ODOO_DB")
  @user_agent %{}

  def login(conn, _params) do
    changeset = Authentication.changeset(%Authentication{})
    render(conn, :login, layout: false, changeset: changeset)
  end

  def authenticate(conn, params) do
    changeset = Authentication.changeset(%Authentication{}, Map.get(params, "authentication"))
    # IO.puts(changeset.username)
    auth = Map.get(params, "authentication")
    %{ "username" => username, "password" => password } = auth
    params = [@database, username, password, @user_agent]

    request_body = %XMLRPC.MethodCall{method_name: "authenticate", params: params}
      |> XMLRPC.encode!

    {:ok, %XMLRPC.MethodResponse{param: id}} =
      HTTPoison.post!(@path, request_body).body
        |> XMLRPC.decode

    conn
    |> put_session(:external_id, id)
    |> put_session(:password, password)
    |> redirect(to: "/")
  end
end
