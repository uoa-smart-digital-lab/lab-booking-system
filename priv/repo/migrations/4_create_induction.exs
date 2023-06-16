defmodule Labbookings.Repo.Migrations.CreateInduction do
  use Ecto.Migration

  def change do
    create table(:induction) do
      add :upi, :string
      add :itemname, :string

      timestamps()
    end
  end
end
