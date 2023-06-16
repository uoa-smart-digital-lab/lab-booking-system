# ****************************************************************************************************
# Define the Session database structure for Ecto
# ****************************************************************************************************
defmodule Labbookings.Bookings.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "session" do
    field :sessionid, :string
    field :upi, :string

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:sessionid, :upi ])
    |> validate_required([:sessionid, :upi ])
  end
end
