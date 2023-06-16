# ****************************************************************************************************
# Core database functions to be used by the resolvers for Booking
# ****************************************************************************************************
defmodule Labbookings.Booking do
  import Ecto.Query, warn: false

  alias Labbookings.Repo
  alias Labbookings.Bookings.Booking

  # ------------------------------------------------------------------------------------------------------
  # Get the bookings by the upi and whether they overlap the optional start and end times
  # TODO: This could get quite inefficient as the number of bookings in the system increase
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_upi(upi), do: get_bookings_by_upi(upi, nil, nil)
  def get_bookings_by_upi(upi, nil, nil) do
    # Get all the bookings with that upi
    query = from p in Booking,
      where: p.upi == ^upi

    # Return the list of bookings for this upi
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  def get_bookings_by_upi(upi, nil, endtime) do
    # Get all the bookings with the upi that are before this endtime or overlap it
    query = from p in Booking,
    where: (p.upi == ^upi) and (((^endtime > p.starttime) and (^endtime < p.endtime)) or (^endtime >= p.endtime))
    # Return the list of bookings that match
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  def get_bookings_by_upi(upi, starttime, nil) do
    # Get all the bookings with the upi that are after this starttime or overlap it
    query = from p in Booking,
      where: (p.upi == ^upi) and (((^starttime > p.starttime) and (^starttime < p.endtime)) or (^starttime <= p.starttime))
    # Return the list of bookings that match
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  def get_bookings_by_upi(upi, starttime, endtime) do
    # Get all the bookings with the upi that overlap this timeframe
    query = from p in Booking,
      where: (p.upi == ^upi) and (((^endtime > p.starttime) and (^endtime < p.endtime)) or
                                  ((^starttime > p.starttime) and (^starttime < p.endtime)) or
                                  ((^starttime <= p.starttime) and (^endtime >= p.endtime)))
    # Return the list of bookings that match
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the booking with the exact itemname and start and end times
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_itemname_and_date(itemname, starttime, endtime) do
    # Get the bookings by the itemname and start and end times
    query = from p in Booking,
      where: (p.itemname == ^itemname) and (p.starttime == ^starttime) and (p.endtime == ^endtime)

    # Return the list of bookings that match
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the bookings by the itemname and whether they overlap the optional start and end times
  # TODO: This could get quite inefficient as the number of bookings in the system increases
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_itemname(itemname), do: get_bookings_by_itemname(itemname, nil, nil)
  def get_bookings_by_itemname(itemname, nil, nil) do
    # Get all the bookings with that itemanme
    query = from p in Booking,
      where: p.itemname == ^itemname

    # Return the list of bookings for this item
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  def get_bookings_by_itemname(itemname, nil, endtime) do
    # Get all the bookings with the itemname that are before this endtime or overlap it
    query = from p in Booking,
    where: (p.itemname == ^itemname) and (((^endtime > p.starttime) and (^endtime < p.endtime)) or (^endtime >= p.endtime))
    # Return the list of bookings that match
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  def get_bookings_by_itemname(itemname, starttime, nil) do
    # Get all the bookings with the itemname that are after this starttime or overlap it
    query = from p in Booking,
      where: (p.itemname == ^itemname) and (((^starttime > p.starttime) and (^starttime < p.endtime)) or (^starttime <= p.starttime))
    # Return the list of bookings that match
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  def get_bookings_by_itemname(itemname, starttime, endtime) do
    # Get all the bookings with the itemname that overlap this timeframe
    query = from p in Booking,
      where: (p.itemname == ^itemname) and (((^endtime > p.starttime) and (^endtime < p.endtime)) or
                                            ((^starttime > p.starttime) and (^starttime < p.endtime)) or
                                            ((^starttime <= p.starttime) and (^endtime >= p.endtime)))
    # Return the list of bookings that match
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new booking
  # ------------------------------------------------------------------------------------------------------
  def create_booking(attrs \\ %{}) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Repo.insert()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Update an existing booking
  # ------------------------------------------------------------------------------------------------------
  def update_booking(%Booking{} = booking, attrs) do
    booking
    |> Booking.changeset(attrs)
    |> Repo.update()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete an existing booking
  # ------------------------------------------------------------------------------------------------------
  def delete_booking(%Booking{} = booking) do
    Repo.delete(booking)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete all the bookings for a given user (for when deleting a user)
  # ------------------------------------------------------------------------------------------------------
  def delete_bookings_by_upi(upi) do
    query = from r in Booking,
    where: r.upi == ^upi

    # Delete all the records that match
    Repo.all(query) |> delete_list()
  end

  defp delete_list([]), do: :ok
  defp delete_list([head | tail]) do
    delete_booking(head)
    delete_list(tail)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete all the bookings for a given item (for when deleting an item)
  # ------------------------------------------------------------------------------------------------------
  def delete_bookings_by_itemname(itemname) do
    query = from r in Booking,
    where: r.itemname == ^itemname

    # Delete all the records that match
    Repo.all(query) |> delete_list()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Change the details on a booking without affecting the database
  # ------------------------------------------------------------------------------------------------------
  def change_induction(%Booking{} = booking, attrs \\ %{}) do
    Booking.changeset(booking, attrs)
  end
  # ------------------------------------------------------------------------------------------------------
end
