defmodule CercleApi.APIV2.CardAttachmentController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Card, CardAttachment, CardAttachmentFile}

  plug CercleApi.Plug.EnsureAuthenticated
  plug CercleApi.Plug.CurrentUser

  # plug :authorize_resource, model: CardAttachment, only: [:create, :delete],
  #   unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  #   not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, %{"card_id" => card_id}) do
    card = Card
    |> Repo.get(card_id)
    |> Repo.preload([:attachments])

    render(conn, "index.json", card_attachments: card.attachments)
  end

  def create(conn, %{"card_id" => card_id, "attachment" => attachment}) do
    card = Repo.get!(Card, card_id)
    changeset = CardAttachment.changeset(
      %CardAttachment{}, %{"card_id" => card_id}
    )
    case Repo.insert(changeset) do
      {:ok, card_attachment} ->
        {_, filename} = CardAttachmentFile.store({attachment, card_attachment})

        changeset = card_attachment
        |> Ecto.Changeset.change(attachment: %{file_name: filename, updated_at: Ecto.DateTime.utc})

        Repo.update(changeset)
        attachment = Repo.get(CardAttachment, card_attachment.id)
        CercleApi.Endpoint.broadcast!(
          "cards:#{card.id}", "card:added_attachment", %{
            "card" => card, "attachment" => CardAttachment.json_data(attachment)
          })
        render(conn, "show.json", card_attachment: attachment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"card_id" => card_id, "id" => id}) do
    card = Repo.get!(Card, card_id)
    attachment = Repo.get!(CardAttachment, id)
    Repo.delete!(attachment)

    CercleApi.Endpoint.broadcast!(
      "cards:#{card.id}", "card:deleted_attachment", %{
        "card" => card, "attachment_id" => id
      })
    json conn, %{status: 200}
  end
end
