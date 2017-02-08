defmodule CercleApi.Repo.Migrations.AddDatafields do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
     	add :data_fields, :map, default: fragment("json_build_object()::jsonb")
    end
  end
end
