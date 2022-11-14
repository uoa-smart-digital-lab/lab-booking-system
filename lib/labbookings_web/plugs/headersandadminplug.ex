defmodule LabbookingsWeb.HeadersAndAdminContext do
  @behaviour Plug

  import Plug.Conn
  alias Labbookings.Session
  alias Labbookings.Person

  # import Ecto.Query

  # alias Labbookings.Repo

  def init(opts) do
    opts
  end

  def call(conn, _) do
    context = get_req_header(conn, "sessionid")
      |> get_user_from_sessionid()
      |> Map.merge(grab_auth_token(conn))

    Absinthe.Plug.put_options(conn, context: context)
  end

  # def parse(conn, opts \\ []) do
  #   opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
  #   Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  # end

  @doc """
  Return the current user context based on the authorization header
  """
  def grab_auth_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      %{auth_token: token}
    else
      _ -> %{}
    end
  end

  def get_user_from_sessionid([]), do:  %{user: nil, sessionid: nil}
  def get_user_from_sessionid([sessionid | _]) do
    case Session.get_session_by_id(sessionid) do
      nil -> %{user: nil, sessionid: sessionid}
      session ->
        case Person.get_person_by_upi(session.upi) do
          nil -> %{user: nil, sessionid: sessionid}
          person -> %{user: person, sessionid: sessionid}
        end
    end
  end
end
