defmodule Labbookings.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:item) do
      add :name, :string
      add :image, :string
      add :url, :string
      add :details, :json

      add :cost, :integer
      add :bookable, :boolean
      add :access, :integer

      timestamps()
    end
  end
end
