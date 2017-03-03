defmodule CercleApi.APIV2.TagsView do
  use CercleApi.Web, :view

  def render("index.json", %{tags: tags}) do
    tags
  end
end
