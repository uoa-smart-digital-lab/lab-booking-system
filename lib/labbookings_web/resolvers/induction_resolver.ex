# ****************************************************************************************************
# Resolve instructions between the induction database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.InductionResolver do
  alias Labbookings.Item
  alias Labbookings.Person
  alias Labbookings.Induction
  alias LabbookingsWeb.PersonResolver

  # ------------------------------------------------------------------------------------------------------
  # Get all inductions in the database
  # ------------------------------------------------------------------------------------------------------
  def all_inductions(_root, _args, _info) do
    {:ok, Induction.list_inductions()}
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all inductions for a person
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_upi(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    Induction.get_inductions_by_upi(upi)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all inductions for an item
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_itemname(_root, args, _info) do
    itemname = Map.get(args, :itemname) |> String.downcase()
    Induction.get_inductions_by_itemname(itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all inductions for a person and item
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_upi_and_itemname(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    itemname = Map.get(args, :itemname) |> String.downcase()
    Induction.get_inductions_by_upi_and_itemname(upi, itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new induction
  # ------------------------------------------------------------------------------------------------------
  def create_induction(_root, args_in, info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))

    case Map.get(info.context, :user) do
      # User not logged in or doesn't exist
      nil -> {:error, :nosession}
      user ->
        # Check whether already inducted to avoid duplicates
        case Induction.get_inductions_by_upi_and_itemname(args.upi, args.itemname) do
          [] ->
            # Check that the specified person to be inducted actually exists
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :upi}
              _person ->
                # Check the item exists
                case Item.get_item_by_name(args.itemname) do
                  nil -> {:error, :item}
                  item ->
                    # Check that the logged in user is allowed to induct the person
                    case check_access(item, user) do
                      {:ok, _} ->
                        # Create the induction record
                        Induction.create_induction(args)
                        # Return the updated person being inducted
                        PersonResolver.send_person_if_allowed(user, Person.get_person_by_upi(args.upi))
                      error ->
                        # The logged in user does not have the right to induct the person
                        error
                    end
                end
            end
          _ ->
            PersonResolver.send_person_if_allowed(user, Person.get_person_by_upi(args.upi))
        end
      end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete inductions if they exist
  # ------------------------------------------------------------------------------------------------------
  def delete_induction(_root, args_in, info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))
    IO.puts "HERE HERE HERE"
    IO.inspect args

    case Map.get(info.context, :user) do
      # User not logged in or doesn't exist
      nil -> {:error, :nosession}
      user ->
        # Check whether induction exists
        case Induction.get_inductions_by_upi_and_itemname(args.upi, args.itemname) do
          [] ->
            PersonResolver.send_person_if_allowed(user, Person.get_person_by_upi(args.upi))
          [induction | _ ] ->
            IO.puts "HERE HERE HERE"
            # Check that the specified person to be inducted actually exists
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :upi}
              _person ->
                # Check the item exists
                case Item.get_item_by_name(args.itemname) do
                  nil -> {:error, :item}
                  item ->
                    # Check that the logged in user is allowed to induct the person
                    case check_access(item, user) do
                      {:ok, _} ->
                        # Create the induction record
                        Induction.delete_induction(induction)
                        # Return the updated person being inducted
                        PersonResolver.send_person_if_allowed(user, Person.get_person_by_upi(args.upi))
                      error ->
                        # The logged in user does not have the right to induct the person
                        error
                    end
                end
            end
        end
      end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Check whether the user has access to the item that they are wanting to induct the person to.
  # ------------------------------------------------------------------------------------------------------
  defp check_access(item, user) do
    # If bookable
    case item.bookable do
      :true ->
        # Check item access level
        case item.access do
          # No restrictions, so no induction required
          :free -> {:error, :noinductionrequired}
          # Has to be used under supervision, so no induction allowed
          :supervised -> {:error, :supervisedonly}
          # Check the status of the logged in user to determine if they can induct
          _ ->
            case check_user_status(user.status, item, user) do
              # Induction allowed
              :true -> {:ok, :inductable}
              # Induction not allowed
              _ -> {:error, :noaccess}
            end
        end
      # Item not bookable
      _ -> {:error, :notbookable}
    end
  end

  # Admin can induct anyone
  defp check_user_status(:admin, _, _) do :true end
  # Poweruser can induct anyone who to items they have been inducted to
  defp check_user_status(:poweruser, item, user) do
    # Check the inductions of the user, and if the item is on that list, induct the person to the item
    case Induction.get_inductions_by_upi_and_itemname(user.upi, item.name) do
      [] -> :false
      _ -> :true
    end
  end
  # Users can't induct anyone
  defp check_user_status(_, _, _) do :false end

  # ------------------------------------------------------------------------------------------------------
end
