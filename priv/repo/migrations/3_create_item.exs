defmodule Labbookings.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:item) do
      add :name, :string
      add :image, :string
      add :url, :string
      add :details, :json

      timestamps()
    end
  end
end
