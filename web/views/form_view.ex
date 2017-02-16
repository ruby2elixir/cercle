defmodule CercleApi.FormView do
  use CercleApi.Web, :view
  
  def auto_submit_selectize(form, field_name, collection, opts \\ []) do
    select(
      form,
      field_name,
      collection,
      opts ++ default_autosubmit_selectize_options
    )
  end
  
  defp default_autosubmit_selectize_options do
    [
      prompt: "Type the name",
      data: [
        selectize: "single",
        autosubmit: "true",
      ],
    ]
  end
end
