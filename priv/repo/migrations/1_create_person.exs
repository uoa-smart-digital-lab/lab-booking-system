defmodule Labbookings.Repo.Migrations.CreatePerson do
  use Ecto.Migration

  def change do
    create table(:person) do
      add :name, :string
      add :upi, :string
      add :password, :string
      add :status, :integer
      add :details, :map

      timestamps()
    end
  end
end
