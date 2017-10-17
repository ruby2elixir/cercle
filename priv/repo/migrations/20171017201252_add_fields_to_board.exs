defmodule CercleApi.Repo.Migrations.AddFieldsToBoard do
  use Ecto.Migration

  def change do
  	alter table(:boards) do
      add :type_of_card, :integer, default: 0
    end
  end
end
