defmodule LabbookingsWeb.PageController do
  use LabbookingsWeb, :controller

  def index(conn, _params) do
    html(conn, File.read!("priv/static/labbookings/build/index.html"))
  end
end
