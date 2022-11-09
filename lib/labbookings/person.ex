# ****************************************************************************************************
# Core database functions to be used by the resolvers for Person
# ****************************************************************************************************
defmodule Labbookings.Person do
  import Ecto.Query, warn: false

  alias Labbookings.Repo
  alias Labbookings.Bookings.Person
  alias LabbookingsWeb.Schema.Enums

  # ------------------------------------------------------------------------------------------------------
  # List all the people in the database
  # ------------------------------------------------------------------------------------------------------
  def list_people do
    query = from p in Person,
    order_by: [asc: :upi]

    Repo.all(query) |> Enums.convert(:status)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a person by their ID
  # ------------------------------------------------------------------------------------------------------
  def get_person(id) do
    # Get all the people with that ID, there should only be one
    query = from p in Person,
      where: p.id == ^id

    # Return either nil if none exist, or the first of the list (in case there was more than one)
    case Repo.all(query) do
      [] -> nil
      [answer | _] -> answer |> Enums.convert(:status)
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a person by their UPI
  # ------------------------------------------------------------------------------------------------------
  def get_person_by_upi(upi) do
    # Get all the people with that UPI, there should only be one
    query = from p in Person,
      where: p.upi == ^upi

    # Return either nil if none exist, or the first of the list (in case there was more than one)
    case Repo.all(query) do
      [] -> nil
      [answer | _] -> answer |> Enums.convert(:status)
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new person record
  # ------------------------------------------------------------------------------------------------------
  def create_person(attrs \\ %{}) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
    |> Enums.convert(:status)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Update a person record
  # ------------------------------------------------------------------------------------------------------
  def update_person(%Person{} = person, attrs) do
    person
    |> Person.changeset(attrs)
    |> Repo.update()
    |> Enums.convert(:status)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete a person record
  # ------------------------------------------------------------------------------------------------------
  def delete_person(%Person{} = person) do
    Repo.delete(person)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Return a person changeset
  # ------------------------------------------------------------------------------------------------------
  def change_person(%Person{} = person, attrs \\ %{}) do
    Person.changeset(person, attrs)
  end
  # ------------------------------------------------------------------------------------------------------
end
