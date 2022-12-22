# ****************************************************************************************************
# Resolve instructions between the booking database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.BookingResolver do
  alias Labbookings.Item
  alias Labbookings.Person
  alias Labbookings.Booking
  alias Labbookings.Induction

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
  # Get all the bookings for an item between speific dates
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_itemname_and_date(_root, args, _info) do
    itemname = Map.get(args, :itemname) |> String.downcase()
    case test_parameters(DateTime.from_iso8601(args.starttime), DateTime.from_iso8601(args.endtime)) do
      {:ok, {starttime, endtime}} -> Booking.get_bookings_by_itemname_and_date(itemname, starttime, endtime)
      error -> error
    end
  end

  defp test_parameters({:ok, starttime, _}, {:ok, endtime, _}), do: {:ok, {starttime, endtime}}
  defp test_parameters({:error, _}, _), do: {:error, :starttime}
  defp test_parameters(_, {:error, _}), do: {:error, :endtime}
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new booking
  # ------------------------------------------------------------------------------------------------------
  def create_booking(_root, args_in, info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))

    # Check that the user is actually logged in
    check_user_logged_in(Map.get(info.context, :user))
      # Check the start time is before the end time
      |> check_start_is_before_end(args.starttime, args.endtime)
      # Ensure the item actually exists
      |> check_item_exists(Item.get_item_by_name(args.itemname))
      # Ensure the person the item is to be booked for actually exists
      |> check_person_exists(Person.get_person_by_upi(args.upi))
      # Check that the user is allowed to book the item for this person
      |> check_user_allowed()
      # Make sure the booking doesn't overlap some other booking for this item
      |> check_overlap_bookings(Booking.get_bookings_by_itemname(args.itemname, args.starttime, args.endtime))
      # Make the booking
      |> make_booking(args)
      # Return the updated item
      |> get_updated_item(args.itemname)
  end
  # ------------------------------------------------------------------------------------------------------


  # ------------------------------------------------------------------------------------------------------
  # Modify an existing booking
  # ------------------------------------------------------------------------------------------------------
  def update_booking(_root, args_in, info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))

    # Check that the user is actually logged in
    check_user_logged_in(Map.get(info.context, :user))
      # Check the start time is before the end time
      |> check_start_is_before_end(args.newstarttime, args.newendtime)
      # Ensure the item actually exists
      |> check_item_exists(Item.get_item_by_name(args.itemname))
      # Ensure the person the item is to be booked for actually exists
      |> check_person_exists(Person.get_person_by_upi(args.upi))
      # Check that the user is allowed to book the item for this person
      |> check_user_allowed()
      # Get the existing booking
      |> get_existing_booking(Booking.get_bookings_by_itemname_and_date(args.itemname, args.starttime, args.endtime))
      # Make sure the booking doesn't overlap some other booking for this item (except the one being changed)
      |> check_overlap_bookings(Booking.get_bookings_by_itemname(args.itemname, args.starttime, args.endtime))
      # Make the booking
      |> update_booking(args)
      # Return the updated item
      |> get_updated_item(args.itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete booking if it exists
  # ------------------------------------------------------------------------------------------------------
  def delete_booking(_root, args_in, info) do
    args = args_in |> Map.replace(:itemname, String.downcase(args_in.itemname))

    # Check that the user is actually logged in
    check_user_logged_in(Map.get(info.context, :user))
      # Ensure the item actually exists
      |> check_item_exists(Item.get_item_by_name(args.itemname))
      # Get the existing booking
      |> get_existing_booking(Booking.get_bookings_by_itemname_and_date(args.itemname, args.starttime, args.endtime))
      # Get the person on the booking
      |> get_person_on_booking()
      # Check that the user is allowed to book the item for this person
      |> check_user_allowed()
      # Delete the booking
      |> delete_booking()
      # Return the updated item
      |> get_updated_item(args.itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Helper functions for above
  # ------------------------------------------------------------------------------------------------------
  defp check_user_logged_in(nil) do {:error, :nosession} end
  defp check_user_logged_in(user) do {:ok, %{:user => user}} end

  defp check_start_is_before_end({:error, error}, _, _) do {:error, error} end
  defp check_start_is_before_end({:ok, data}, starttime, endtime) do
    case DateTime.compare(starttime, endtime) do
      :lt -> {:ok, data}
      _ -> {:error, :wrongorder}
    end
  end

  defp check_item_exists({:error, error}, _) do {:error, error} end
  defp check_item_exists({:ok, _}, nil) do {:error, :item} end
  defp check_item_exists({:ok, data}, item) do {:ok, Map.put(data, :item, item)} end

  defp check_person_exists({:error, error}, _) do {:error, error} end
  defp check_person_exists({:ok, _}, nil) do {:error, :upi} end
  defp check_person_exists({:ok, data}, person) do {:ok, Map.put(data, :person, person)} end

  defp get_person_on_booking({:error, error}) do {:error, error} end
  defp get_person_on_booking({:ok, data}) do
    person = Person.get_person_by_upi(data.booking.upi)
    {:ok, Map.put(data, :person, person)}
  end

  defp check_user_allowed({:error, error}) do {:error, error} end
  defp check_user_allowed({:ok, data}) do
    case check_access(data.item, data.user, data.person) do
      {:ok, _} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp get_existing_booking({:error, error}, _) do {:error, error} end
  defp get_existing_booking({:ok, _}, []) do {:error, :notexist} end
  defp get_existing_booking({:ok, data}, [booking | _]) do
    {:ok, Map.put(data, :booking, booking)}
  end

  defp check_overlap_bookings({:error, error}, _) do {:error, error} end
  defp check_overlap_bookings({:ok, data}, []) do {:ok, data} end
  defp check_overlap_bookings({:ok, data}, bookings) do
    case remove_booking_from_bookings(Map.get(data, :booking), bookings) do
      [] -> {:ok, data}
      _ -> {:error, :overlap}
    end
  end

  defp remove_booking_from_bookings(nil, _) do {:error, :overlap} end
  defp remove_booking_from_bookings(_, []) do [] end
  defp remove_booking_from_bookings(booking, [booking | tail]) do tail end
  defp remove_booking_from_bookings(booking, [head | tail]) do [head | remove_booking_from_bookings(booking, tail)] end

  defp make_booking({:error, error}, _) do {:error, error} end
  defp make_booking({:ok, data}, args) do
    case Booking.create_booking(args) do
      {:error, _} -> {:error, :internalerror}
      _ -> {:ok, data}
    end
  end

  defp update_booking({:error, error}, _) do {:error, error} end
  defp update_booking({:ok, data}, args) do
    newargs = args |> Map.replace(:starttime, args.newstarttime) |> Map.replace(:endtime, args.newendtime)
    # Create the booking record
    case Booking.update_booking(data.booking, newargs) do
      {:error, _} -> {:error, :internalerror}
      _ -> {:ok, data}
    end
  end

  defp delete_booking({:error, error}) do {:error, error} end
  defp delete_booking({:ok, data}) do
    # Create the booking record
    case Booking.delete_booking(data.booking) do
      {:error, _} -> {:error, :internalerror}
      _ -> {:ok, data}
    end
  end

  defp get_updated_item({:error, error}, _) do {:error, error} end
  defp get_updated_item({:ok, _}, itemname) do
    case Item.get_item_by_name(itemname) do
      {:error, _} -> {:error, :internalerror}
      item -> {:ok, item}
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Check whether the user has been inducted to the item that they are wanting to book for the person.
  # ------------------------------------------------------------------------------------------------------
  defp check_access(item, user, person) do
    # Get the inductions for this item
    inductions = Induction.get_inductions_by_itemname(item.name)

    # If bookable
    case item.bookable do
      :true ->
        # Check item access level
        case item.access do
          # No restrictions, so just do the booking
          :free -> {:ok, :bookable}
          # Has to be used under supervision, so no only booking by admins and powerusers
          :supervised ->
            case user.status do
              :admin ->
                # Is the person who is to booked the item inducted to use the item?
                case is_person_inducted(inductions, person.upi) do
                  :true -> {:ok, :bookable}
                  _ -> {:error, :notinducted}
                end
              :poweruser ->
                # Can only book items for others if they themselves are inducted as well as the other
                case is_person_inducted(inductions, user.upi) and is_person_inducted(inductions, person.upi) do
                  :true -> {:ok, :bookable}
                  _ -> {:error, :notinducted}
                end
                _ -> {:error, :supervisedonly}
              end

          # Check the status of the logged in user to determine if they can induct
          _ ->
            case user.status do
              :admin ->
                # Is the person who is to booked the item inducted to use the item?
                case is_person_inducted(inductions, person.upi) do
                  :true -> {:ok, :bookable}
                  _ -> {:error, :notinducted}
                end
              :poweruser ->
                # Can only book items for others if they themselves are inducted as well as the other
                case is_person_inducted(inductions, user.upi) and is_person_inducted(inductions, person.upi) do
                  :true -> {:ok, :bookable}
                  _ -> {:error, :notinducted}
                end
              _ ->
                case is_person_inducted(inductions, person.upi) and (user.upi == person.upi) do
                  :true -> {:ok, :bookable}
                  _ -> {:error, :notinducted}
                end
            end
        end
      # Item not bookable
      _ -> {:error, :notbookable}
    end
  end

  defp is_person_inducted([], _) do :false end
  defp is_person_inducted([head | tail], upi) do
    case head.upi == upi do
      :true -> :true
      _ -> is_person_inducted(tail, upi)
    end
  end
  # ------------------------------------------------------------------------------------------------------
end
