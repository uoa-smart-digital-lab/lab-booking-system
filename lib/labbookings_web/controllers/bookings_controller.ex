defmodule LabbookingsWeb.BookingsController do
  use LabbookingsWeb, :controller

  def index(conn, _params) do
    html(conn, File.read!("priv/static/bookings/dist/index.html"))
  end
end
