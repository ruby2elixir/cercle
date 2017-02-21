defmodule CercleApi.Repo.Migrations.AddDefaultValueToUserTimezone do
  use Ecto.Migration

  def change do
  	 alter table(:users) do
  	 	modify :time_zone, :string, default: "America/New_York"
  	 end

  end
end
