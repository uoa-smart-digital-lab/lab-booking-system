# ****************************************************************************************************
# Core database functions to be used by the resolvers for Session
# ****************************************************************************************************
defmodule Labbookings.Session do
  import Ecto.Query, warn: false

  alias Labbookings.Repo
  alias Labbookings.Bookings.Session

  # ------------------------------------------------------------------------------------------------------
  # List all the sessions in the database
  # ------------------------------------------------------------------------------------------------------
  def list_sessions do
    Repo.all(Session)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the Session given the upi
  # ------------------------------------------------------------------------------------------------------
  def get_session_by_upi(upi) do
    # Get all the sessions with that upi, there should only be one
    query = from p in Session,
      where: p.upi == ^upi

    # Return either nil if none exist, or the first of the list (in case there was more than one)
    case Repo.all(query) do
      [] -> nil
      [answer | _] -> answer
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the session given the sessionid
  # ------------------------------------------------------------------------------------------------------
  def get_session_by_id(sessionid) do
    # Get all the sessions with that sessonid, there should only be one
    query = from p in Session,
      where: p.sessionid == ^sessionid

    # Return either nil if none exist, or the first of the list (in case there was more than one)
    case Repo.all(query) do
      [] -> nil
      [answer | _] -> answer
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new session
  # ------------------------------------------------------------------------------------------------------
  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Update an existing session
  # ------------------------------------------------------------------------------------------------------
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete an existing session
  # ------------------------------------------------------------------------------------------------------
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Change the details on a session without affecting the database
  # ------------------------------------------------------------------------------------------------------
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end
  # ------------------------------------------------------------------------------------------------------
end
