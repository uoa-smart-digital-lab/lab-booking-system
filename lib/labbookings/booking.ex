# ****************************************************************************************************
# Core database functions to be used by the resolvers for Booking
# ****************************************************************************************************
defmodule Labbookings.Booking do
  import Ecto.Query, warn: false

  alias Labbookings.Repo
  alias Labbookings.Bookings.Booking

  # ------------------------------------------------------------------------------------------------------
  # List all the bookings in the database
  # ------------------------------------------------------------------------------------------------------
  def list_bookings do
    Repo.all(Booking)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the Bookings given the upi
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_upi(upi) do
    # Get all the bookings with that upi
    query = from p in Booking,
      where: p.upi == ^upi

    # Return the list of bookigns for this person
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the bookings for the itemname
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_itemname(itemname) do
    # Get all the bookings with that itemanme
    query = from p in Booking,
      where: p.itemname == ^itemname

    # Return the list of bookings for this item
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the bookings given the upi and itemname
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_upi_and_itemname(upi, itemname) do
    # Get all the bookings with the upi and itemanme
    query = from p in Induction,
      where: (p.itemname == ^itemname) and (p.upi == ^upi)

    # Return the list of bookings for this person and item
    case Repo.all(query) do
      nil -> []
      bookings -> bookings
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the bookings by the itemname and whether they overlap the given timeframe
  # ------------------------------------------------------------------------------------------------------
  def get_bookings_by_itemname_and_date(itemname, starttime, endtime) do
    # Get all the bookings with the itemname that overlap this timeframe
    query = from p in Booking,
      where: (p.itemname == ^itemname) and (((p.starttime >= ^starttime) and (p.endtime >= ^endtime)) or ((p.starttime <= ^starttime) and (p.endtime <= ^endtime)) or ((p.starttime >= ^starttime) and (p.endtime <= ^endtime)) or ((p.starttime <= ^starttime) and (p.starttime >= ^endtime)))

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
    |> Induction.changeset(attrs)
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
