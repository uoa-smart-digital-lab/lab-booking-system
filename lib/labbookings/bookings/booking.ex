# ****************************************************************************************************
# Define the Booking database structure for Ecto
# ****************************************************************************************************
defmodule Labbookings.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "booking" do
    field :itemname, :string
    field :upi, :string
    field :details, :map

    field :starttime, :utc_datetime
    field :endtime, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(induction, attrs) do
    induction
    |> cast(attrs, [:upi, :itemname, :details, :starttime, :endtime])
    |> validate_required([:upi, :itemname, :details, :starttime, :endtime])
  end
end
