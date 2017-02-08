defmodule CercleApi.Repo.Migrations.CreateCode do
  use Ecto.Migration

  def change do
    create table(:codes) do
      add :code, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :company_id, references(:companies, on_delete: :nothing)

      timestamps
    end
    create index(:codes, [:user_id])
    create index(:codes, [:company_id])

  end
end
