# ****************************************************************************************************
# Resolve instructions between the session database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.SessionResolver do
  alias Labbookings.Session
  alias Labbookings.Person

  # ------------------------------------------------------------------------------------------------------
  # Get all sessions in the database
  # ------------------------------------------------------------------------------------------------------
  def all_sessions(_root, _args, _info) do
    {:ok, Session.list_sessions()}
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a single session record given the sessionid or upi
  # ------------------------------------------------------------------------------------------------------
  def get_session(_root, args, _info) do
    sessionid = get_sessionid_safely_from_args(args)
    get_session_by_id_or_upi(Map.get(args, :upi), sessionid)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a session by sessionid or upi if it exists
  # ------------------------------------------------------------------------------------------------------
  def get_session_by_id_or_upi(nil, nil) do
    {:error, :noparam}
  end
  def get_session_by_id_or_upi(upi, nil) do
    case Session.get_session_by_upi(upi |> String.downcase()) do
      nil -> {:error, :nosession}
      answer -> {:ok, answer}
    end
  end
  def get_session_by_id_or_upi(_, sessionid) do
    case Session.get_session_by_id(sessionid) do
      nil -> {:error, :nosession}
      answer -> {:ok, answer}
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new session, testing the password, and replacing an existing one for the user if it exists.
  # ------------------------------------------------------------------------------------------------------
  def create_session(_root, args, _info) do
    case Person.get_person_by_upi(Map.get(args, :upi) |> String.downcase()) do
      nil -> {:error, :nosession}
      person ->
        if Bcrypt.verify_pass(args.password, person.password) do
          case Session.get_session_by_upi(args.upi |> String.downcase()) do
            nil ->
              case args |> Map.put(:sessionid, UUID.uuid4()) |> Map.replace(:upi, args.upi |> String.downcase()) |> Session.create_session() do
                {:ok, result} ->
                  {:ok, result}
                _ ->
                  {:error, :internalerror}                
              end
            session ->
              case Session.update_session(session, args |> Map.put(:sessionid, UUID.uuid4()) |> Map.replace(:upi, args.upi |> String.downcase())) do
                {:ok, result} ->
                  {:ok, result}
                _ ->
                  {:error, :internalerror}
              end
          end
        else
          {:error, :badpassword}
        end
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete a session if it exists
  # ------------------------------------------------------------------------------------------------------
  def delete_session(_root, _args, info) do
    sessionid = info.context.sessionid
    case Session.get_session_by_id(sessionid) do
      nil -> {:error, :nosession}
      session ->
        case Session.delete_session(session) do
          {:ok, result} ->
            {:ok, result}
          _ ->
            {:error, :internalerror}
        end
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Safely extract the sessionid in lowercase from the args map, or nil of not there.
  # ------------------------------------------------------------------------------------------------------
  def get_sessionid_safely_from_args(args) do
    case Map.get(args, :sessionid) do
      nil -> nil
      sessionid -> sessionid |> String.downcase()
    end
  end
  # ------------------------------------------------------------------------------------------------------

end
