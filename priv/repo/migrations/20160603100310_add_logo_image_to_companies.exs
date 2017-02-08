defmodule CercleApi.Repo.Migrations.AddLogoImageToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :logo_image, :string
    end
  end
end
