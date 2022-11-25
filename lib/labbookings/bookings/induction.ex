# ****************************************************************************************************
# Define the Induction database structure for Ecto
# ****************************************************************************************************
defmodule Labbookings.Bookings.Induction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "induction" do
    field :upi, :string
    field :itemname, :string

    timestamps()
  end

  @doc false
  def changeset(induction, attrs) do
    induction
    |> cast(attrs, [:upi, :itemname ])
    |> validate_required([:upi, :itemname ])
  end
end
