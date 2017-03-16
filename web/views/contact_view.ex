defmodule CercleApi.ContactView do
  use CercleApi.Web, :view
  import CercleApi.FormView, only: [auto_submit_selectize: 3, auto_submit_selectize: 4]
  alias CercleApi.Organization
  alias CercleApi.Repo

  def words do
    Organization |> Repo.all |> build_selectize_options
  end

  defp build_selectize_options(collection) do
    Enum.map collection, fn(element) ->
      {element.name, element.id}
    end
  end

  defp build_selectize_options2(collection) do
    Enum.map collection, fn(element) ->
      {element.name, element.id}
    end
  end
end
