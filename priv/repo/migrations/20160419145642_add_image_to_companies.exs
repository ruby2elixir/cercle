defmodule CercleApi.Repo.Migrations.AddImageToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :image, :string
    end
  end
end
