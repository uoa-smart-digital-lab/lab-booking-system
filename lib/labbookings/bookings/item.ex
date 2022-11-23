# ****************************************************************************************************
# Define the Item database structure for Ecto
# ****************************************************************************************************
defmodule Labbookings.Bookings.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "item" do
    field :name, :string
    field :image, :string
    field :url, :string
    field :details, :map

    field :cost, :int
    field :bookable, :boolean
    field :access, :int

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs|> Enums.convert(:access), [:name, :image, :url, :details, :cost, :bookable, :access])
    |> validate_required([:name, :image, :url, :details, :cost, :bookable, :access])
  end
end
