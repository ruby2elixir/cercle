defmodule CercleApi.Repo.Migrations.CreateCompanyService do
  use Ecto.Migration

  def change do
    create table(:company_services) do
      add :company_id, :integer
      add :name, :string

      timestamps
    end

  end
end
