# ****************************************************************************************************
# Resolve instructions between the person database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.PersonResolver do
  alias Labbookings.Person
  alias Labbookings.Induction
  alias LabbookingsWeb.ItemResolver


  # ------------------------------------------------------------------------------------------------------
  # Fill the person schema, recursively going into the items as required.
  # ------------------------------------------------------------------------------------------------------
  def fill_person_schema(args) do
    case Person.get_person_by_upi(args.upi |> String.downcase()) do
      {:ok, person} ->
        case Map.get(args.inductions) do
          nil -> person |> Map.replace(:password, "")
          _ ->
            items = get_items_from_inductions(args.inductions, Induction.get_inductions_by_upi(args.upi))
            person |> Map.replace(:password, "") |> Map.put(:inductions, items)
        end
    end
  end

  defp get_items_from_inductions(_, nil), do: []
  defp get_items_from_inductions(_, []), do: []
  defp get_items_from_inductions(args, [head | tail]) do
    [ ItemResolver.fill_item_schema(args |> Map.put(:name, head.itemname)) | get_items_from_inductions(args, tail) ]
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all people in the database
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def all_people(_root, args, info) do
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        case Map.get(user, :status) do
          :admin -> {:ok, Person.list_people() |> process_person_list(args)}
          :poweruser -> {:ok, Person.list_people() |> process_person_list(args)}
          _ -> {:error, :notadmin}
        end
    end
  end

  defp process_person_list([], _), do: []
  defp process_person_list([head | tail], args) do
    items = get_items_from_inductions(args, Induction.get_inductions_by_upi(head.upi))
    [ head |> Map.replace(:password, "") |> Map.put(:inductions, items) | process_person_list(tail, args) ]
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a single person record given their database ID or UPI
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def get_person(_root, args_in, info) do
    args = Map.replace(args_in, :upi, String.downcase(args_in.upi))

    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        send_person_if_allowed(user, fill_person_schema(args))
    end
  end

  # Either the person is admin or poweruser, or the person upi matches the sessionid upi
  defp send_person_if_allowed(nil, _), do: {:error, :nosession}
  defp send_person_if_allowed(user, person) do
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
