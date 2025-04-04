defmodule OdooHoursWeb.PageControllerTest do
  use OdooHoursWeb.ConnCase

  test "GET / redirects without session", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET / renders with session", %{conn: conn} do
    conn = conn
    |> Plug.Test.init_test_session(external_id: 1, password: "123")
    |> get(~p"/")

    assert html_response(conn, 200) =~ "Hello 1"
  end
end
