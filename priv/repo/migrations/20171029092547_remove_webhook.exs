defmodule CercleApi.Repo.Migrations.RemoveWebhook do
  use Ecto.Migration

  def change do
  	drop table(:webhook_subscriptions)
  end
end
