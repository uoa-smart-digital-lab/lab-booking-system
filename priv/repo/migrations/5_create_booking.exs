defmodule Labbookings.Repo.Migrations.CreateBooking do
  use Ecto.Migration

  def change do
    create table(:booking) do
      add :upi, :string
      add :itemname, :string
      add :details, :json

      add :starttime, :utc_datetime
      add :endtime, :utc_datetime

      timestamps()
    end
  end
end
