defmodule CercleApi.Repo.Migrations.AddFieldsToUsers2map do
  use Ecto.Migration

  def change do
  	alter table(:contacts) do
     	add :data, :map, default: fragment("json_build_object()::jsonb")
    end
  end
end
