defmodule LabbookingsWeb.CheckInPageController do
  use LabbookingsWeb, :controller

  def index(conn, _params) do
    html(conn, File.read!("priv/static/checkin/build/index.html"))
  end
end
