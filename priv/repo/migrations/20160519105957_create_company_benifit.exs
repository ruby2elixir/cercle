defmodule CercleApi.Repo.Migrations.CreateCompanyBenifit do
  use Ecto.Migration

  def change do
    create table(:company_benifits) do
      add :company_id, :integer
      add :name_of_the_brand, :string
      add :title, :string
      add :content, :text
      add :image, :string
      add :redirection_url, :string
      add :local, :boolean
      add :local_street, :string
      add :local_city, :string
      add :local_zipcode, :string
      add :local_country, :string

      timestamps
    end

  end
end
