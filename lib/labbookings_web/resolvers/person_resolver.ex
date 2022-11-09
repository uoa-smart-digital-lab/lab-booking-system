# ****************************************************************************************************
# Resolve instructions between the person database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.PersonResolver do
  alias Labbookings.Person
  # alias Labbookings.Occupancy
  # alias Labbookings.Participant


  # ------------------------------------------------------------------------------------------------------
  # Get all people in the database
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def all_people(_root, _args, info) do
    case Map.get(info.context, :user) do
      nil -> {:error, :notadmin}
      user ->
        case Map.get(user, :status) do
          :admin -> {:ok, Person.list_people() |> remove_passwords()}
          :poweruser -> {:ok, Person.list_people() |> remove_passwords()}
          _ -> {:error, :notadmin}
        end
    end
  end

  defp remove_passwords([]), do: []
  defp remove_passwords([head | tail]) do
    [Map.replace(head, :password, "") | remove_passwords(tail)]
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a single person record given their database ID or UPI
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def get_person(_root, args_in, info) do
    args = Map.replace(args_in, :upi, String.downcase(args_in.upi))
    case Map.get(args, :upi) do
      nil -> {:error, :noperson}
      upi ->
        case Person.get_person_by_upi(upi) do
          nil -> {:error, :noperson}
          person ->
            case Map.get(info.context, :user) do
              nil -> {:error, :notadmin}
              user -> send_person_if_allowed(user, person)
            end
        end
    end
  end

  # Either the person is admin or poweruser, or the person upi matches the sessionid upi
  defp send_person_if_allowed(nil, _), do: {:error, :nosession}
  defp send_person_if_allowed(user, person) do
    if user.upi == person.upi do
      {:ok, person |> Map.replace(:password, "")}
    else
      case Map.get(user, :status) do
        :admin -> {:ok, person |> Map.replace(:password, "")}
        :poweruser -> {:ok, person |> Map.replace(:password, "")}
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
        ) do
          {:ok, newperson} -> {:ok, newperson |> Map.replace(:password, "")}
          error -> error
        end
      _ ->
        case Map.get(info.context, :user) do
          nil -> {:error, :notadmin}
          user ->
            case Map.get(user, :status) do
              :admin ->
                case Person.get_person_by_upi(args.upi) do
                  nil ->
                    case Person.create_person(
                      args
                      |> Map.replace(:password, encrypted_password)
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
      nil -> {:error, :notadmin}
      user ->
        case Map.get(user, :status) do
          :admin ->
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :noperson}
              answer ->
                case Person.update_person(answer, args |> replace_password(Map.get(args, :password))) do
                  {:ok, updated_person} -> {:ok, updated_person |> Map.replace(:password, "")}
                  error -> error
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
      nil -> {:error, :notadmin}
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
                    {:error, :problemdeletingperson}
                end
            end
          _ -> {:error, :notadmin}
        end
      end
  end
  # ------------------------------------------------------------------------------------------------------
end
