# ****************************************************************************************************
# Core database functions to be used by the resolvers for Induction
# ****************************************************************************************************
defmodule Labbookings.Induction do
  import Ecto.Query, warn: false

  alias Labbookings.Repo
  alias Labbookings.Bookings.Induction

  # ------------------------------------------------------------------------------------------------------
  # List all the inductions in the database
  # ------------------------------------------------------------------------------------------------------
  def list_inductions do
    Repo.all(Induction)
  end
  # ------------------------------------------------------------------------------------------------------



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
  # Change the details on a induction without affecting the database
  # ------------------------------------------------------------------------------------------------------
  def change_induction(%Induction{} = induction, attrs \\ %{}) do
    Induction.changeset(induction, attrs)
  end
  # ------------------------------------------------------------------------------------------------------
end
