defmodule OdooHours.Client do
  @moduledoc"""
  A client to interface with the odoo API
  """

  defstruct [:database, :url]

  @path "/xmlrpc/2/common"
  @user_agent %{}

  @doc """
  Authenticates to odoo, and gives the means to perform subsequent requests
  """
  @spec authenticate(config :: %OdooHours.Client{}, username :: String.t(), password :: String.t()) ::
    {:ok, integer()} | {:error, any()}
  def authenticate(config, username, password) do
    params = [config.database, username, password, @user_agent]

    request_body = %XMLRPC.MethodCall{method_name: "authenticate", params: params}
    |> XMLRPC.encode!

  {:ok, %XMLRPC.MethodResponse{param: id}} =
    HTTPoison.post!(url(config), request_body).body
      |> XMLRPC.decode

  {:ok, id}
  end

  @spec url(config: %OdooHours.Client{}) :: String.t()
  defp url(%OdooHours.Client{ url: base_url }) do
    "#{base_url}#{@path}"
  end
end
