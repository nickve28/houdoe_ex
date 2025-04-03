defmodule OdooHours.Client do
  require Logger

  @moduledoc"""
  A client to interface with the odoo API
  """

  defstruct [:database, :url, :id, :password]

  @auth_path "/xmlrpc/2/common"
  @object_path "/xmlrpc/2/object"
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
    HTTPoison.post!(auth_url(config), request_body).body
      |> XMLRPC.decode

  {:ok, id}
  end

  def user_entries(config, id, password, options \\ []) do
    options =
      Keyword.merge(
        [
          limit: 10,
          where: [],
          fields: []
        ],
        options
      )

    execute_kw(
      config,
      id,
      password,
      "account.analytic.line",
      "search_read",
      [
        [
          ["user_id", "=", id]
        ] ++ options[:where]
      ],
      %{
        "fields" => options[:fields],
        "limit" => options[:limit]
      }
    )
    # |> atomize_keys()
  end


  defp execute_kw(config, id, password, model_name, method_name, params \\ [], named_params \\ %{}) do
    %OdooHours.Client{ database: database} = config

    call(config, "execute_kw", [
      database,
      id,
      password,
      model_name,
      method_name,
      params,
      named_params
    ])
  end

  defp call(config, method, params \\ []) do
    request = %XMLRPC.MethodCall{method_name: method, params: params} |> XMLRPC.encode!()

    response_body = HTTPoison.post!(url(config), request).body
    {:ok, response} = response_body |> XMLRPC.decode()

    case response do
      %XMLRPC.MethodResponse{} ->
        Logger.debug("response: #{inspect response.param, pretty: true}")
        response.param

      %XMLRPC.Fault{} ->
        raise "Odoo error (code #{inspect(response.fault_code)}) #{response.fault_string}"

      err ->
        raise "#{inspect(err)}"
    end
  end

  @spec auth_url(config: %OdooHours.Client{}) :: String.t()
  defp auth_url(%OdooHours.Client{ url: base_url }) do
    "#{base_url}#{@auth_path}"
  end

  @spec url(config: %OdooHours.Client{}) :: String.t()
  defp url(%OdooHours.Client{ url: base_url }) do
    "#{base_url}#{@object_path}"
  end
end
