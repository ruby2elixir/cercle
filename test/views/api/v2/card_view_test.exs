defmodule CercleApi.APIV2.CardViewTest do
  use CercleApi.ConnCase, async: true
  import CercleApi.Factory
  alias CercleApi.APIV2.ActivityView
  use Timex

  test "card_json" do
    board = insert(:board)
    board_column = insert(:board_column)
    card = insert(:card,
      due_date: Timex.now(),
      board: board,
      board_column: board_column)

    assert CercleApi.APIV2.CardView.card_json(card) == %{
      id: card.id,
      company_id: card.company_id,
      name: card.name,
      description: card.description,
      due_date: card.due_date,
      status: card.status,
      contact_ids: card.contact_ids,
      user_id: card.user_id,
      board: board,
      board_column: board_column,
      contact: nil
    }

  end
end
