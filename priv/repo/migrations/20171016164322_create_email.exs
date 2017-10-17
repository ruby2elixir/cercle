defmodule CercleApi.Repo.Migrations.CreateEmail do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :uid, :string
      add :company_id, :integer
      add :subject, :string
      add :from_email, :string
      add :to_email, :string
      add :body, :text
      add :date, :utc_datetime

      timestamps()
    end

    create unique_index(:emails, [:uid])
  end
end
