defmodule Labbookings.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:item) do
      add :name, :string
      add :image, :string
      add :url, :string
      add :details, :json

      add :cost, :int
      add :bookable, :boolean
      add :access, :int

      timestamps()
    end
  end
end
