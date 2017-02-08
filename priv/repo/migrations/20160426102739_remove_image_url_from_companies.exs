defmodule CercleApi.Repo.Migrations.RemoveImageUrlFromCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      remove :image_url
    end
  end
end
