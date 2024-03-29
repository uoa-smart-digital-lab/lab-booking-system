# ****************************************************************************************************
# Core database functions to be used by the resolvers for Item
# ****************************************************************************************************
defmodule Labbookings.Item do
  import Ecto.Query, warn: false

  alias Labbookings.Repo
  alias Labbookings.Bookings.Item
  alias LabbookingsWeb.Schema.Enums

  # ------------------------------------------------------------------------------------------------------
  # List all the items in the database
  # ------------------------------------------------------------------------------------------------------
  def list_items do
    query = from p in Item,
    order_by: [asc: :name]

    Repo.all(query) |> Enums.convert(:access)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the Item given the ID
  # ------------------------------------------------------------------------------------------------------
  def get_item(id) do
    # Get all the items with that ID, there should only be one
    query = from p in Item,
      where: p.id == ^id

    # Return either nil if none exist, or the first of the list (in case there was more than one)
    case Repo.all(query) do
      [] -> nil
      [answer | _] -> answer |> Enums.convert(:access)
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get the item given the name
  # ------------------------------------------------------------------------------------------------------
  def get_item_by_name(name) do
    # Get all the items with that name, there should only be one
    query = from p in Item,
      where: p.name == ^name

    # Return either nil if none exist, or the first of the list (in case there was more than one)
    case Repo.all(query) do
      [] -> nil
      [answer | _] -> answer |> Enums.convert(:access)
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new item
  # ------------------------------------------------------------------------------------------------------
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
    |> Enums.convert(:access)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Update an existing item
  # ------------------------------------------------------------------------------------------------------
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
    |> Enums.convert(:access)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete an existing item
  # ------------------------------------------------------------------------------------------------------
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Change the details on a item without affecting the database
  # ------------------------------------------------------------------------------------------------------
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
  # ------------------------------------------------------------------------------------------------------
end
