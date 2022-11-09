# ****************************************************************************************************
# Define the Person database structure for Ecto
# ****************************************************************************************************
defmodule Labbookings.Bookings.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias LabbookingsWeb.Schema.Enums


  schema "person" do
    field :name, :string
    field :upi, :string
    field :password, :string
    field :status, :integer

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> Enums.convert(:status)
    |> cast(attrs |> Enums.convert(:status), [:name, :upi, :password, :status])
    |> validate_required([:name, :upi, :password, :status])
  end
end
