defmodule CercleApi.ImportView do
  use CercleApi.Web, :view

  @contact_fields ["first_name", "last_name", "full_name",
                   "email", "description", "phone", "job_title"]
  @organization_fields ["name", "website", "description"]

  def render("mapping.json", %{table: table, uuid: uuid}) do
    [headers|rows]= table
    first_row = Enum.at(rows, 0)
    top_five_rows = Enum.take(rows, 5)

    %{
      headers: headers,
      first_row: first_row,
      top_five_rows: top_five_rows,
      contact_fields: @contact_fields,
      organization_fields: @organization_fields,
      temp_file: uuid
    }
  end

  def render("preview_data.json", %{mapping: mapping, table: table, uuid: uuid}) do
    total_rows = Enum.count(table) - 1
    contact_headers = Map.keys(mapping["contact"])
    organization_headers = Map.keys(mapping["organization"])
    header = Enum.map(Enum.at(table, 0), &String.strip(&1))
    first_row = Enum.zip(header, Enum.at(table, 1)) |> Enum.into(%{})
    contact_values = for {db_col, csv_col} <- mapping["contact"] do
      first_row[csv_col]
    end
    organization_values = for {db_col, csv_col} <- mapping["organization"] do
      first_row[csv_col]
    end

    %{
      contact_headers: contact_headers,
      organization_headers: organization_headers,
      contact_values: contact_values,
      organization_values: organization_values,
      temp_file: uuid
    }
  end
end
