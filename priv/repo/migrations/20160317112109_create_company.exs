defmodule CercleApi.Repo.Migrations.CreateCompany do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :title, :string
      add :description1, :text
      add :description2, :text

      timestamps
    end

  end
end
