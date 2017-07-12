defmodule CercleApi.APIV2.CardView do
  use CercleApi.Web, :view

  def render("index.json", %{cards: cards}) do
    %{data: render_many(cards, CercleApi.APIV2.CardView, "card.json")}
  end

  def render("show.json", %{card: card}) do
    %{data: render_one(card, CercleApi.APIV2.CardView, "card.json")}
  end

  def render("card.json", %{card: card}) do
    card_json(card)
  end

  def render("full_card.json",
    %{card: card,
      card_contacts: card_contacts,
      board: board, attachments: attachments}) do
    %{
      card: card,
      activities:  card.activities,
      events: card.timeline_event,
      card_contacts: card_contacts,
      board: board,
      board_columns: board.board_columns,
      attachments: attachments
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
      board: card.board,
      board_column: card.board_column
    }
  end
end
