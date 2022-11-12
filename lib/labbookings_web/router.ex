defmodule LabbookingsWeb.Router do
  use LabbookingsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, {LabbookingsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LabbookingsWeb do
    pipe_through :browser
    get "/", PageController, :index
    # get "/rooms", PageController, :index
    get "/admin", AdminPageController, :index
    # get "/checkin", CheckInPageController, :index
  end


  pipeline :api do
    plug :accepts, ["json"]
    plug LabbookingsWeb.HeadersAndAdminContext
  end

  scope "/api" do
    pipe_through :api

    forward "/", Absinthe.Plug,
    init_opts: [schema: LabbookingsWeb.Schema, json_codec: Jason]

    # schema: LabbookingsWeb.Schema
  end

  # Enables LiveDashboard and graphiql only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/dashboard" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/", metrics: LabbookingsWeb.Telemetry
    end

    scope "/" do
      pipe_through :api

      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: LabbookingsWeb.Schema,
        # interface: :simple,
        # interface: :advanced,
        interface: :playground,
        context: %{pubsub: LabbookingsWeb.Endpoint}
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running iethe Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
