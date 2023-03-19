defmodule LabbookingsWeb.Admin2PageController do
  use LabbookingsWeb, :controller

  def index(conn, _params) do
    html(conn, File.read!("priv/static/admin2/dist/index.html"))
  end
end
