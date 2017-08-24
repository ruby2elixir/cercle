defmodule CercleApi.APIV2.BoardColumnView do
  use CercleApi.Web, :view

  def render("index.json", %{board_columns: board_columns}) do
    %{data: render_many(board_columns, CercleApi.APIV2.BoardColumnView, "board_column.json")}
  end

  def render("show.json", %{board_column: board_column}) do
    %{data: render_one(board_column, CercleApi.APIV2.BoardColumnView, "board_column.json")}
  end

  def render("board_column.json", %{board_column: board_column}) do
    %{
      id: board_column.id,
      name: board_column.name
    }
  end

  def render("board_column_with_cards.json", %{board_column: board_column}) do
    %{id: board_column.id,
      name: board_column.name,
      cards: Enum.map(
        CercleApi.Card.preload_main_contact_and_user(board_column.cards),
        fn (card) -> card_json(card) end
      )
    }
  end

  def card_json(card) do
    %{
      id: card.id,
      company_id: card.company_id,
      name: card.name,
      description: card.description,
      due_date: card.due_date,
      status: card.status,
      contact_ids: card.contact_ids,
      user_id: card.user_id,
      user: card.user,
      board: card.board_id,
      board_column: card.board_column_id,
      main_contact: card.main_contact
    }
  end

end
