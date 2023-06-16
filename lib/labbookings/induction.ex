# ****************************************************************************************************
# Core database functions to be used by the resolvers for Induction
# ****************************************************************************************************
defmodule Labbookings.Induction do
  import Ecto.Query, warn: false

  alias Labbookings.Repo
  alias Labbookings.Bookings.Induction

  # ------------------------------------------------------------------------------------------------------
  # Get the Induction given the upi
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_upi(upi) do
    # Get all the inductions with that upi
    query = from p in Induction,
      where: p.upi == ^upi

    # Return the list of inductions for this person
    case Repo.all(query) do
      nil -> []
      inductions -> inductions
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the induction given the itemname
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_itemname(itemname) do
    # Get all the inductions with that itemanme
    query = from p in Induction,
      where: p.itemname == ^itemname

    # Return the list of inductions for this item
    case Repo.all(query) do
      nil -> []
      inductions -> inductions
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the induction given the upi and itemname
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_upi_and_itemname(upi, itemname) do
    # Get all the inductions with the upi and itemanme
    query = from p in Induction,
      where: (p.itemname == ^itemname) and (p.upi == ^upi)

    # Return the list of inductions for this person and item
    case Repo.all(query) do
      nil -> []
      inductions -> inductions
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new induction
  # ------------------------------------------------------------------------------------------------------
  def create_induction(attrs \\ %{}) do
    %Induction{}
    |> Induction.changeset(attrs)
    |> Repo.insert()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Update an existing induction
  # ------------------------------------------------------------------------------------------------------
  def update_induction(%Induction{} = induction, attrs) do
    induction
    |> Induction.changeset(attrs)
    |> Repo.update()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete an existing induction
  # ------------------------------------------------------------------------------------------------------
  def delete_induction(%Induction{} = induction) do
    Repo.delete(induction)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete all the inductions for a given user (for when deleting a user)
  # ------------------------------------------------------------------------------------------------------
  def delete_inductions_by_upi(upi) do
    query = from r in Induction,
    where: r.upi == ^upi

    # Delete all the records that match
    Repo.all(query) |> delete_list()
  end

  defp delete_list([]), do: :ok
  defp delete_list([head | tail]) do
    delete_induction(head)
    delete_list(tail)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete all the inductions for a given item (for when deleting an item)
  # ------------------------------------------------------------------------------------------------------
  def delete_inductions_by_itemname(itemname) do
    query = from r in Induction,
    where: r.itemname == ^itemname

    # Delete all the records that match
    Repo.all(query) |> delete_list()
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Change the details on a induction without affecting the database
  # ------------------------------------------------------------------------------------------------------
  def change_induction(%Induction{} = induction, attrs \\ %{}) do
    Induction.changeset(induction, attrs)
  end
  # ------------------------------------------------------------------------------------------------------
end
