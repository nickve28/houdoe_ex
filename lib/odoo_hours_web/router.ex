defmodule OdooHoursWeb.Router do
  use OdooHoursWeb, :router

  pipeline :protected do
    plug OdooHoursWeb.Plugs.EnsureSession
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OdooHoursWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OdooHoursWeb do
    pipe_through [:browser, :protected]

    get "/", PageController, :home
    live "/hours", Liveviews.HoursLive
  end

  scope "/authentication", OdooHoursWeb do
    pipe_through :browser

    get "/login", AuthenticationController, :login
    post "/authenticate", AuthenticationController, :authenticate
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:odoo_hours, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OdooHoursWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
