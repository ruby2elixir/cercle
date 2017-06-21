defmodule CercleApi.ImportController do
  @moduledoc """
  upload and parse import contact file.
  """

  use CercleApi.Web, :controller
  use Timex

  alias CercleApi.{Company, Tag, Card, ImportContactFile}

  require Logger

  def import(conn, _params) do
    conn
      |> put_layout("adminlte.html")
      |> render("import.html")
  end

  def import_data(conn, %{"file" => upload_file}) do
    file_type = upload_file.content_type
    items = ImportContactFile.parse(upload_file, file_type)

    changeset = %ImportContactFile{}
    |> ImportContactFile.changeset(
      %{"content" => %{items: items}, "content_type" => file_type}
    )

    case Repo.insert(changeset) do
      {:ok, import_file} ->
        render(conn, "mapping.json", table: items, uuid: import_file.uuid)
      {:error, :changeset} ->
        json conn, %{error_message: "Maximum 10,000 records are permitted"}
    end

  end

  def view_uploaded_data(conn, %{"mapping" => mapping, "temp_file" => uuid}) do
    import_file = Repo.get_by!(ImportContactFile, uuid: uuid)
    table = import_file.content["items"]
    render(conn, "preview_data.json",
      mapping: mapping, table: table, uuid: uuid
    )
  end

  def create_nested_data(conn, %{"mapping" => mapping, "temp_file" => temp_file}) do
    user = Guardian.Plug.current_resource(conn)
    import_file = Repo.get_by!(ImportContactFile, uuid: temp_file)
    [_|rows] = import_file.content["items"]
    header = ImportContactFile.header(import_file)
    total_rows = Enum.count(rows) - 1
    iterations = div(total_rows, 100)
    str_tag_id = imported_tag_id(user)
    responses  = for n <- 0..iterations do
      lower..upper = (n * 100..(n + 1) * 100 -1)
      if upper > total_rows do
        upper = total_rows - 1
      end

      items = for i <- lower..upper do
        row_data = %{}
        row = prepare_row(rows, i, header)
        contact_data = contact_data_mapping(row, mapping["contact"])
        organization_data = organization_data_mapping(row, mapping["organization"])

        Map.put(row_data, "contact", contact_data)
        |> Map.put("organization", organization_data)
      end

      contacts = CercleApi.APIV2.BulkController.bulk_contact_create(
        conn, %{"items" => items, "return" => true}
      )
      CercleApi.APIV2.BulkController.bulk_tag_or_untag_contacts(conn,
        %{
          "contacts" => contacts, "tag_id" => str_tag_id,
          "untag" => false, "return" => true
        })
    end

    Repo.delete!(import_file)
    json conn, %{status: "200", message: "Records imported successfully"}
  end

  defp contact_data_mapping(row, mapping) do
    %{
      "first_name" => row[mapping["first_name"]],
      "last_name" => row[mapping["last_name"]],
      "full_name" => row[mapping["full_name"]],
      "email" => row[mapping["email"]],
      "phone" => row[mapping["phone"]],
      "description" => row[mapping["description"]],
      "job_title" => row[mapping["job_title"]]
    }
  end

  defp organization_data_mapping(row, mapping) do
    %{
      "name" => row[mapping["name"]],
      "website" => row[mapping["website"]],
      "description" => row[mapping["description"]]
    }
  end

  defp imported_tag_id(user) do
    datetime = Timezone.convert(Timex.now, user.time_zone)
    date = Timex.format!(datetime, "%m/%d/%Y", :strftime)
    time = Timex.format!(datetime, "%H:%M", :strftime)
    tag_name = "imported #{date} at #{time}"
    tag = %Tag{name: tag_name, company_id: user.company_id}
    |> Repo.insert!
    Integer.to_string(tag.id)
  end

  defp prepare_row(rows, index, header) do
    row = Enum.at(rows, index)
    |> Enum.map(&String.strip(&1))
    Enum.zip(header, row)
    |> Enum.into(%{})
  end
end
