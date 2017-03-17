defmodule CercleApi.APIV2.BulkController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Contact, Organization, Tag, ContactTag}

  plug Guardian.Plug.EnsureAuthenticated

  def bulk_contact_create(conn,%{"items" => items, "tag_id" => tag_id}) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    for item <- items do
      organization_params = Map.put(item["organization"], "company_id", company_id)
      contact_params =  Map.put(item["contact"], "user_id", user.id)
      contact_params = Map.put(contact_params, "company_id", company_id)
      ext_org = Repo.get_by(Organization, name: organization_params["name"], company_id: company_id)
      if ext_org do
        contact_params = Map.put(contact_params,"organization_id",ext_org.id)
      else
        changeset = Organization.changeset(%Organization{}, organization_params)
        organization = Repo.insert!(changeset)
        contact_params = Map.put(contact_params,"organization_id",organization.id)
      end

      changeset = Contact.changeset(%Contact{}, contact_params)
      case Repo.insert(changeset) do
        {:ok, contact} ->
          contact = Repo.get!(Contact, contact.id)
          if tag_id do
            query = from tag in Tag,
              where: tag.id == ^tag_id
            tags = Repo.all(query)
                changeset = contact
              |> Repo.preload(:tags) # Load existing data
              |> Ecto.Changeset.change() # Build the changeset
              |> Ecto.Changeset.put_assoc(:tags, tags)
            Repo.update!(changeset)
          end
      end
    end
    json conn, %{status: "200", message: "Records imported successfully"}
  end

  def bulk_tag_or_untag_contacts(conn,%{"contacts" => contacts, "tag_id" => tag_id}) do
    responses = []
    if Enum.count(contacts) > 100 do
      json conn, %{status: "422", error_message: "Maximum 100 records are permitted per call"}
    else
      if contacts && tag_id do
        {tag_id, _rest} = Integer.parse(tag_id)
        tag = Repo.get(Tag,tag_id)
        if tag do
          user = Guardian.Plug.current_resource(conn)
          company_id = user.company_id
          responses = for c <- contacts do
            if c do
              {contact_id, _rest} = Integer.parse(c)
              contact = Repo.get(Contact,contact_id)
              if contact do
                # untag them
                query = from c in ContactTag,
                  where: c.contact_id == ^contact.id and c.tag_id == ^tag.id
                tagged = Repo.all(query)
                if Enum.count(tagged) > 0 do
                  Repo.delete_all(query)
                else
                # tag them
                  query = from tag in Tag,
                    where: tag.id == ^tag.id
                  tags = Repo.all(query)
                      changeset = contact
                    |> Repo.preload(:tags) # Load existing data
                    |> Ecto.Changeset.change() # Build the changeset
                    |> Ecto.Changeset.put_assoc(:tags, tags) # Set the association
                  Repo.update!(changeset)
                end
                %{status: "200", success: "Contact id #{contact.id} tagged/untagged successfully"}
              else
                %{status: "400", error: "Contact id #{c} not found"}
              end
            else
              %{status: "400", error: "Contact id missing"}
            end
          end
          json conn, %{status: "200", responses: responses}
        else
          json conn, %{status: "400", responses: %{"errors" => "Tag id #{tag_id} not found"}}
        end
      else
        json conn, %{status: "400", responses: %{"errors" => "Parameters missing"}}
      end
    end
  end
end