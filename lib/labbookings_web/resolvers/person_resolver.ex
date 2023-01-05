# ****************************************************************************************************
# Resolve instructions between the person database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.PersonResolver do
  alias Labbookings.Person
  alias Labbookings.Induction
  alias Labbookings.Booking


  # ------------------------------------------------------------------------------------------------------
  # Get all people in the database
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def all_people(_root, args_in, info) do
    args = Map.merge(args_in, info.context)
    # Get the logged in user record
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        {:ok, Person.list_people() |> add_args(args) |> process_person_list(user)}
    end
  end

  defp add_args([], _), do: []
  defp add_args([head | tail], args), do: [head |> Map.merge(%{__args__: args}) | add_args(tail, args)]
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a single person record given their database ID or UPI
  # Only admins or powerusers can do this, or if the sessionid upi and user upi match
  # ------------------------------------------------------------------------------------------------------
  def get_person(_root, args_in, info) do
    # Make sure the input argument for upi is in lowercase
    args = Map.replace(args_in, :upi, String.downcase(args_in.upi))
    case Person.get_person_by_upi(args.upi) |> tune_for_user(Map.get(info.context, :user)) do
      nil -> {:error, :noperson}
      person -> {:ok, person |> Map.merge(%{__args__: args})}
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Go through the list of persons and fill out the list
  # ------------------------------------------------------------------------------------------------------
  defp process_person_list([], _), do: []
  defp process_person_list([head | tail], user) do
    [ head |> tune_for_user(user) | process_person_list(tail, user) ]
  end
  # ------------------------------------------------------------------------------------------------------


  # ------------------------------------------------------------------------------------------------------
  # Tune a person map to be suitable for a specific user
  # ------------------------------------------------------------------------------------------------------
  def tune_for_user(nil, _), do: nil
  def tune_for_user(person, nil), do: person |> remove_sensitive()
  def tune_for_user(person, user) do
    if user.upi == person.upi do
      person |> remove_password()
    else
      case user.status do
        :admin -> person |> remove_password()
        :poweruser ->
          case person.status do
            :admin -> person |> remove_sensitive()
            _ -> person |> remove_password()
          end
        _ -> person |> remove_sensitive()
      end
    end
  end
  defp remove_password(person), do: person |> Map.replace(:password, "")
  defp remove_sensitive(person) do
    person |> Map.replace(:tokens, -1) |> Map.replace(:password, "")
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
                    # Get rid of references to the user in the inductions and bookings databases.
                    Induction.delete_inductions_by_upi(args.upi)
                    Booking.delete_bookings_by_upi(args.upi)
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



  # ------------------------------------------------------------------------------------------------------
  # Change the number of tokens a person has - can only be done by admins.  Tokens will be used as a form
  # of payment for using equipment.
  # ------------------------------------------------------------------------------------------------------
  def adjust_tokens(_root, args_in, info) do
    args = Map.replace(args_in, :upi, String.downcase(args_in.upi))
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        case Map.get(user, :status) do
          :admin ->
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :noperson}
              person ->
                case Person.update_person(person, args |> Map.replace(:tokens, args.tokens)) do
                  {:ok, updated_person} -> {:ok, updated_person |> Map.replace(:password, "")}
                  _ -> {:error, :internalerror}
                end
            end
          _ -> {:error, :notadmin}
        end
    end
  end
  # ------------------------------------------------------------------------------------------------------
end
