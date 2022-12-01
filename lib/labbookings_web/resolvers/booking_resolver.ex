# ****************************************************************************************************
# Resolve instructions between the booking database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.BookingResolver do
  alias Labbookings.Item
  alias Labbookings.Person
  alias Labbookings.Booking

  # ------------------------------------------------------------------------------------------------------
  # Get all bookings in the database
  # ------------------------------------------------------------------------------------------------------
  def all_bookings(_root, _args, _info) do
    {:ok, Booking.list_bookings()}
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all bookings for a person
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_upi(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    Booking.get_bookings_by_upi(upi)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all bookings for an item
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_itemname(_root, args, _info) do
    itemname = Map.get(args, :itemname) |> String.downcase()
    Booking.get_bookings_by_itemname(itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all bookings for a person and item
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_upi_and_itemname(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    itemname = Map.get(args, :itemname) |> String.downcase()
    Booking.get_bookings_by_upi_and_itemname(upi, itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all the bookings for an item between speific dates
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_itemname_and_date(_root, args, _info) do
    itemname = Map.get(args, :itemname) |> String.downcase()
    Booking.get_bookings_by_itemname_and_date(itemname, args.starttime, args.endtime)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new booking
  # ------------------------------------------------------------------------------------------------------
  def create_booking(_root, args_in, info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))

    case Map.get(info.context, :user) do
      # User not logged in or doesn't exist
      nil -> {:error, :nosession}
      user ->
        # Check whether already booked to avoid duplicates TODO: Check doesn't overlap with proposed time
        case Booking.get_bookings_by_itemname_and_date(args.itemname, args.starttime, args.endtime) do
          [] ->
            # Check that the specified person to have the item booked for actually exists
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :upi}
              _person ->
                # Check the item exists
                case Item.get_item_by_name(args.itemname) do
                  nil -> {:error, :item}
                  item ->
                    # Check that the logged in user is allowed to book the item
                    case check_access(item, user) do
                      {:ok, _} ->
                        # Create the booking record
                        Booking.create_booking(args)
                        # Return the updated item being booked
                        {:ok, Item.get_item_by_name(args.itemname)}
                      error ->
                        # The logged in user does not have the right to induct the person
                        error
                    end
                end
            end
          _ ->
            {:ok, Item.get_item_by_name(args.itemname)}
        end
      end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Modify an existing booking
  # ------------------------------------------------------------------------------------------------------
  def update_booking(_root, args_in, info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))

    case Map.get(info.context, :user) do
      # User not logged in or doesn't exist
      nil -> {:error, :nosession}
      user ->
        # Check whether already booked to avoid duplicates TODO: Check doesn't overlap with proposed time
        case Booking.get_bookings_by_itemname_and_date(args.itemname, args.starttime, args.endtime) do
          [] ->
            {:ok, Item.get_item_by_name(args.itemname)}
          [ booking | _] ->
            # Check that the specified person to have the item booking updated for actually exists
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :upi}
              _person ->
                # Check the item exists
                case Item.get_item_by_name(args.itemname) do
                  nil -> {:error, :item}
                  item ->
                    # Check that the logged in user is allowed to update the booking
                    case check_access(item, user) do
                      {:ok, _} ->
                        newargs = args |> Map.replace(:starttime, args.newstarttime) |> Map.replace(:endtime, args.newendtime)
                        # Create the booking record
                        Booking.update_booking(booking, newargs)
                        # Return the updated item the bookings is modified for
                        {:ok, Item.get_item_by_name(args.itemname)}
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
  # Delete booking if it exists
  # ------------------------------------------------------------------------------------------------------
  def delete_booking(_root, args_in, info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))

    case Map.get(info.context, :user) do
      # User not logged in or doesn't exist
      nil -> {:error, :nosession}
      user ->
        # Check whether booking exists TODO Add in times
        case Booking.get_bookings_by_upi_and_itemname(args.upi, args.itemname) do
          [] ->
            {:ok, Item.get_item_by_name(args.itemname)}
          [booking | _ ] ->
            # Check that the specified person to remove the booking for actually exists
            case Person.get_person_by_upi(args.upi) do
              nil -> {:error, :upi}
              _person ->
                # Check the item exists
                case Item.get_item_by_name(args.itemname) do
                  nil -> {:error, :item}
                  item ->
                    # Check that the logged in user is allowed to book the item
                    case check_access(item, user) do
                      {:ok, _} ->
                        # REmove the booking record
                        Booking.delete_booking(booking)
                        # Return the updated item the booking is deleted from
                        {:ok, Item.get_item_by_name(args.itemname)}
                      error ->
                        # The logged in user does not have the right to book the item
                        error
                    end
                end
            end
        end
      end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Check whether the user has access to the item that they are wanting to book for the person.
  # ------------------------------------------------------------------------------------------------------
  defp check_access(item, _user) do
    # If bookable
    case item.bookable do
      :true ->
        # Check item access level
        case item.access do
          # No restrictions, so just do the booking
          :free -> {:ok, :bookable}
          # Has to be used under supervision, so no booking allowed
          :supervised -> {:error, :supervisedonly}
          # Check the status of the logged in user to determine if they can induct
          _ -> {:ok, :bookable}
            # case check_user_status(user.status, item, user) do
            #   # Booking allowed
            #   :true -> {:ok, :inductable}
            #   # Booking not allowed
            #   _ -> {:error, :notadmin}
            # end
        end
      # Item not bookable
      _ -> {:error, :notbookable}
    end
  end

  # # Admin can book anything
  # defp check_user_status(:admin, _, _) do :true end
  # # Poweruser can book items for anyone (and themselves) that they have been inducted for
  # defp check_user_status(:poweruser, item, user) do
  #   # Check the inductions of the user, and if the item is on that list, induct the person to the item
  #   case Booking.get_inductions_by_upi_and_itemname(user.upi, item.name) do
  #     [] -> :false
  #     _ -> :true
  #   end
  # end
  # # Ordinary users can only book for themselves that they are inducted for, or which require no induction
  # defp check_user_status(_, _, _) do :false end

  # ------------------------------------------------------------------------------------------------------
end
