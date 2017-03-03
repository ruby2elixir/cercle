defmodule CercleApi.APIV2.TagsController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.Tag

  def index(conn, _params) do
    tags = Repo.all(Tag)
    render(conn, "index.json", tags: tags)
  end

end
