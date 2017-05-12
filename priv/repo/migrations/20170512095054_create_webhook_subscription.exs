defmodule CercleApi.Repo.Migrations.CreateWebhookSubscription do
  use Ecto.Migration

  def change do
    create table(:webhook_subscriptions) do
      add :user_id, :integer
      add :event, :string
      add :url, :string

      timestamps()
    end

  end
end
