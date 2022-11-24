# ****************************************************************************************************
# Define the Item database structure for Ecto
# ****************************************************************************************************
defmodule Labbookings.Bookings.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias LabbookingsWeb.Schema.Enums

  schema "item" do
    field :name, :string
    field :image, :string
    field :url, :string
    field :details, :map

    field :cost, :integer
    field :bookable, :boolean
    field :access, :integer

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> Enums.convert(:access)
    |> cast(attrs|> Enums.convert(:access), [:name, :image, :url, :details, :cost, :bookable, :access])
    |> validate_required([:name, :image, :url, :details, :cost, :bookable, :access])
  end
end
