defmodule CercleApi.Repo.Migrations.AddBoards do
  use Ecto.Migration

  def change do
  	create table(:boards) do
      add :company_id, :integer
      add :metadata, :map, default: fragment("json_build_object()::jsonb")
      timestamps
  	end

  	alter table(:users) do
     	add :last_opened_board_id, :integer
    end

    alter table(:opportunities) do
     	add :board_id, :integer
    end

  end
end
