defmodule OdooHours.Client do
  require Logger

  @moduledoc"""
  A client to interface with the odoo API
  """

  @type t :: %__MODULE__{
    database: String.t(),
    url: String.t()
  }
  @enforce_keys [:database, :url]
  defstruct [:database, :url]

  @auth_path "/xmlrpc/2/common"
  @object_path "/xmlrpc/2/object"
  @user_agent %{}

  @default_user_hours_fields [
    "id",
    "category",
    "can_edit",
    "plan_id",
    "unit_amount",
    "product_uom_id",
    "date",
    "name",
    "task_id",
    "holiday_id",
    "product_id",
    "validated",
    "amount",
    "display_name",
    "is_timesheet"
  ]

  # %{
  #   "amount" => 0.0,
  #   "can_edit" => true,
  #   "category" => "other",
  #   "date" => "2025-12-31",
  #   "display_name" => "Internal Project - Leaves - default",
  #   "holiday_id" => [10195,
  #    "--- op Wettelijk verlof 2025: 24.00 uren op 29-12-2025"],
  #   "id" => <number>,
  #   "is_timesheet" => true,
  #   "name" => "Time Off (3/3)",
  #   "plan_id" => [4, "- Default"],
  #   "product_id" => false,
  #   "product_uom_id" => [6, "Hour(s)"],
  #   "task_id" => [13, "Leaves - default"],
  #   "unit_amount" => 8.0,
  #   "validated" => false
  # }

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

  @spec user_entries(OdooHours.Client.t(), any(), any()) :: any()
  def user_entries(config, id, password, options \\ []) do
    options =
      Keyword.merge(
        [
          limit: 10,
          where: [],
          fields:  @default_user_hours_fields

        ],
        options
      )

      [
        [
          ["user_id", "=", id]
        ] ++ options[:where]
      ]

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
    |> atomize_keys()
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

  defp atomize_keys(list) when is_list(list), do: Enum.map(list, &atomize_keys/1)
  defp atomize_keys(%{} = map), do: Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
end
