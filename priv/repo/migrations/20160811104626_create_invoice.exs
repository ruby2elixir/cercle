defmodule CercleApi.Repo.Migrations.CreateInvoice do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :company_id, :integer
      add :ref_no, :string
      add :stripe_invoice_id, :string
      add :date, :datetime
      add :amount, :integer

      timestamps
    end

  end
end
