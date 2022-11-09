defmodule LabbookingsWeb.AdminPageController do
  use LabbookingsWeb, :controller

  def index(conn, _params) do
    html(conn, File.read!("priv/static/admin/build/index.html"))
  end
end
