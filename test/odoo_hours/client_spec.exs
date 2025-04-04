defmodule OdooHours.Client do
  use ExUnit.Case, async: false

  import Mock

  setup do
    authentication_success_response = """
    <methodCall>
      <methodName>authenticate</methodName>
      <params>
        <param>
            <value><integer>1</integer></value>
            </param>
      </params>
    </methodCall>
    """
  end

  test "#authenticate authenticates the user" do
    with_mock HTTPotion, [post: fn(_url) -> authentication_success_response end] do
      config = %OdooHours.Client{
        database: "testdb",
        url: "http://localhost:3000"
      }
      assert {:ok, id} = OdooHours.Client.authenticate(
        config,
        "username",
        "password"
      )
    end

    assert render_to_string(OdooHoursWeb.ErrorHTML, "404", "html", []) == "Not Found"
  end
end
