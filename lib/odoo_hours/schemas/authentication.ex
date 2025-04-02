defmodule Authentication do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :username
    field :password
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :password])
  end
end
