defmodule CercleApi.BoardNotificationService do
  @moduledoc false

  alias CercleApi.{Repo, Notificaton}

  def update_notification(board) do
    CercleApi.Endpoint.broadcast!(
      "board:#{board.id}", "board:updated", %{
        "board" => CercleApi.APIV2.BoardView.board_json(board)
      })
  end

end
