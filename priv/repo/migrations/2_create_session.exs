defmodule Labbookings.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
    create table(:session) do
      add :sessionid, :string
      add :upi, :string

      timestamps()
    end
  end
end
