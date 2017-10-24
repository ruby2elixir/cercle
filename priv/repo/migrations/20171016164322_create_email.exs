defmodule CercleApi.Repo.Migrations.CreateEmail do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :uid, :string
      add :company_id, :integer
      add :subject, :string
      add :from_email, :string
      add :to, {:array, :string}
      add :cc, {:array, :string}
      add :bcc, {:array, :string}
      add :body, :text
      add :date, :utc_datetime
      add :meta, :jsonb

      timestamps()
    end

    create unique_index(:emails, [:uid])
    create index(:emails, [:to], using: :gin)
    create index(:emails, [:cc], using: :gin)
    create index(:emails, [:bcc], using: :gin)
  end
end
