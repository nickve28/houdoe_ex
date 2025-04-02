defmodule OdooHours.Repo do
  use Ecto.Repo,
    otp_app: :odoo_hours,
    adapter: Ecto.Adapters.SQLite3
end
