defmodule CercleApi.Repo.Migrations.AddStripeCustomerIdToCompany do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :stripe_customer_id, :string
      add :stripe_plan_id, :string
      add :stripe_subscription_id, :string
    end
  end
end
