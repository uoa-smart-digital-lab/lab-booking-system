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

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :image, :url, :details])
    |> validate_required([:name, :image, :url, :details])
  end
end
