defmodule CercleApi.Repo.Migrations.ChangeContactsNameField do
  use Ecto.Migration

  def change do
    rename table(:contacts), :name, to: :first_name
    alter table(:contacts) do
      add :last_name, :string
    end
  end
end
