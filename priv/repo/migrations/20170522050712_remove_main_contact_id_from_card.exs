defmodule CercleApi.Repo.Migrations.RemoveMainContactIdFromCard do
  use Ecto.Migration

  def up do

    Enum.each(CercleApi.Repo.all(CercleApi.Card), fn (card)->
      {:ok, res} = Ecto.Adapters.SQL.query(CercleApi.Repo,"select main_contact_id from cards where id = #{card.id}",[])
      main_contact_id = List.first(List.first(res.rows))
      if main_contact_id do
        card_params = %{ main_contact_id: main_contact_id }
        changeset = CercleApi.Card.changeset(card, card_params)
        CercleApi.Repo.update(changeset)
      end
      card
    end)

    alter table(:cards) do
      remove :main_contact_id
    end
  end

  def down do
    alter table(:cards) do
      add :main_contact_id, :integer
    end
  end
end
