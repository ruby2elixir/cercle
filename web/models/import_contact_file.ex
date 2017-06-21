defmodule CercleApi.ImportContactFile do
  @moduledoc """
  ImportContactFile is the place where is keep import file
  """

  use CercleApi.Web, :model
  alias __MODULE__

  @csv_mime "text/csv"
  @xls_mime "application/vnd.ms-excel"
  @xlsx_mime "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  schema "import_contact_files" do
    field :content, :map
    field :content_type, :string
    field :status, :string, default: "init"
    field :uuid, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :content_type, :status])
    |> generate_uuid
    |> validate_required([:content, :content_type, :uuid])
    |> validate_inclusion(:content_type, [@csv_mime, @xls_mime, @xlsx_mime])
    |> unique_constraint(:uuid)
  end

  def generate_uuid(changeset) do
    put_change(changeset, :uuid, Ecto.UUID.generate)
  end

  def items(import_file) do
    import_file.content["items"]
  end

  def parse(file, "text/csv") do
    file.path
    |> File.read!
    |> ExCsv.parse!
    |> Enum.to_list
  end

  def parse(file, content_type) do
    parser = cond do
      Enum.member?([@xls_mime], content_type) -> Exoffice.Parser.Excel2003
      Enum.member?([@xlsx_mime], content_type) -> Exoffice.Parser.Excel2007
      true -> nil
    end
    if parser do
       [ok: parser_pid] = parser.parse(file.path)
       items = Enum.to_list(Exoffice.get_rows(parser_pid, parser))
       Exoffice.close(parser_pid, parser)
       items
    else
      []
    end
  end
end
