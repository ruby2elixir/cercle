defimpl Canada.Can, for: CercleApi.User do
  alias CercleApi.{Contact, Board, Organization,
                   Card, CardAttachment,
                   BoardColumn, TimelineEvent,
                   Repo, UserCompany}

  def can?(user, action, contact = %Contact{}) when action in [:show, :delete, :update] do
    if user_has_company(user, contact.company_id), do: true, else: false
  end

  def can?(user, action, board = %Board{}) when action in [:show, :delete, :update] do
    if user_has_company(user, board.company_id), do: true, else: false
  end

  def can?(user, action, organization = %Organization{}) when action in [:show, :delete, :update] do
    if user_has_company(user, organization.company_id), do: true, else: false
  end

  def can?(user, action, card = %Card{}) when action in [:delete, :update, :show] do
    if user_has_company(user, card.company_id), do: true, else: false
  end

  def can?(user, action, timeline_event = %TimelineEvent{}) when action in [:delete, :update] do
    if user.id == timeline_event.user_id, do: true, else: false
  end

  # def can?(user, action, opportunity_attachment = %OpportunityAttachment{}) when action in [:create, :delete] do
  #   if user.id == opportunity_attachment.user_id, do: true, else: false
  # end

  def can?(user, action, board_col = %BoardColumn{}) when action in [:delete, :update] do
    board = CercleApi.Repo.get!(Board, board_col.board_id)
    if user_has_company(user, board.company_id), do: true, else: false
  end

  defp user_has_company(user, company_id) do
    UserCompany
    |> Repo.get_by(user_id: user.id, company_id: company_id)
  end
end
