# ****************************************************************************************************
# Resolve instructions between the person database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.PersonResolver do
  alias Labbookings.Person


  # ------------------------------------------------------------------------------------------------------
  # Get all people in the database
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def all_people(_root, _args, info) do
    # Get the logged in user record
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        {:ok, Person.list_people() |> process_person_list(user)}
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a single person record given their database ID or UPI
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def get_person(_root, args_in, info) do
    # Make sure the input argument for upi is in lowercase
    args = Map.replace(args_in, :upi, String.downcase(args_in.upi))

    # Get the currently logged in user record
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        # Send the reply only if allowed to
        send_person_if_allowed(user, Person.get_person_by_upi(args.upi) |> Map.replace(:password, ""))
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Go through the list of persons and fill out the list
  # ------------------------------------------------------------------------------------------------------
  defp process_person_list([], _), do: []
  defp process_person_list([head | tail], user) do
    case send_person_if_allowed(user, head) do
      {:ok, _} -> [ head |> Map.replace(:password, "") | process_person_list(tail, user) ]
      _ -> process_person_list(tail, user)
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Either the person is admin or poweruser, or the person upi matches the sessionid upi
  # ------------------------------------------------------------------------------------------------------
  def send_person_if_allowed(nil, _), do: {:error, :nosession}
  def send_person_if_allowed(user, person) do
    if user.upi == person.upi do
      {:ok, person}
    else
      case Map.get(user, :status) do
        :admin -> {:ok, person}
        :poweruser -> {:ok, person}
        _ -> {:error, :notadmin}
      end
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new person if one with the UPI doesn't already exist
  # Only admins can create new people
  # The first person to be added to the database will automatically become admin
  # ------------------------------------------------------------------------------------------------------
  def create_person(_root, args_in, info) do
    args = Map.replace(args_in, :upi, String.downcase(args_in.upi))
    encrypted_password = Bcrypt.Base.hash_password(args.password, Bcrypt.Base.gen_salt(12, true))
    case Person.list_people() do
      [] ->
        case Person.create_person(
          args
          |> Map.replace(:status, :admin)
          |> Map.replace(:password, encrypted_password)
          |> Map.put(:tokens, 0)
        ) do
          {:ok, newperson} -> {:ok, newperson |> Map.replace(:password, "")}
          error -> error
        end
      _ ->
        case Map.get(info.context, :user) do
          nil -> {:error, :nosession}
          user ->
            case Map.get(user, :status) do
              :admin ->
                case Person.get_person_by_upi(args.upi) do
                  nil ->
                    case Person.create_person(
                      args
                      |> Map.replace(:password, encrypted_password)
                      |> Map.put(:tokens, 0)
                    ) do
                      {:ok, newperson} -> {:ok, newperson |> Map.replace(:password, "")}
                      error -> error
                    end
                  _ -> {:error, :personexists}
                end
              _ -> {:error, :notadmin}
            end
        end
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Modify an existing person
  # Only admins can modify people
  # ------------------------------------------------------------------------------------------------------
  def update_person(_root, args_in, info) do
    args = Map.replace(args_in, :upi, String.downcase(args_in.upi))
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        case Map.get(user, :status) do
          :admin ->
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :noperson}
              answer ->
                case Person.update_person(answer, args |> replace_password(Map.get(args, :password))) do
                  {:ok, updated_person} -> {:ok, updated_person |> Map.replace(:password, "")}
                  _ -> {:error, :internalerror}
                end
            end
          _ -> {:error, :notadmin}
        end
    end
  end

  defp replace_password(args, nil), do: args
  defp replace_password(args, password), do: Map.replace(args, :password, Bcrypt.Base.hash_password(password, Bcrypt.Base.gen_salt(12, true)))
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete a person if they exist
  # Only admins can delete people
  # ------------------------------------------------------------------------------------------------------
  def delete_person(_root, args, info) do
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        case Map.get(user, :status) do
          :admin ->
            case Person.get_person_by_upi(args.upi |> String.downcase()) do
              nil -> {:error, :noperson}
              answer ->
                case Person.delete_person(answer) do
                  {:ok, result} ->
                    # Get rid of references to the user in the occupancy and participant databases.
                    # Occupancy.delete_occupancy_by_upi(args.upi)
                    # Participant.delete_participants_by_upi(args.upi)
                    {:ok, result |> Map.replace(:password, "")}
                  _ ->
                    {:error, :internalerror}
                end
            end
          _ -> {:error, :notadmin}
        end
      end
  end
  # ------------------------------------------------------------------------------------------------------
end
