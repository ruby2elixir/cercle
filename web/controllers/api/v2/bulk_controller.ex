defmodule CercleApi.APIV2.BulkController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Contact, Organization, Tag, ContactTag}

  plug Guardian.Plug.EnsureAuthenticated

  def bulk_contact_create(conn,%{"items" => items}) do
    if Enum.count(items) <= 100 do
      user = Guardian.Plug.current_resource(conn)
      company_id = user.company_id
      contacts = for item <- items do
        organization_params = Map.put(item["organization"], "company_id", company_id)
        if organization_params["id"] do
          ext_org = Repo.get_by(Organization, id: organization_params["id"], company_id: company_id)
        end

        contact_params = Map.put(item["contact"], "user_id", user.id)
        contact_params = Map.put(contact_params, "company_id", company_id)

        if contact_params["id"] do
          ext_contact = Repo.get_by(Contact, id: contact_params["id"], company_id: company_id)
        else contact_params["email"]
          ext_contact = Repo.get_by(Contact, email: contact_params["email"], company_id: company_id)
        end

        if ext_org do
          contact_params = Map.put(contact_params,"organization_id",ext_org.id)
        else
          changeset = Organization.changeset(%Organization{}, organization_params)
          organization = Repo.insert!(changeset)
          contact_params = Map.put(contact_params,"organization_id",organization.id)
        end

        if ext_contact do
          changeset = Contact.changeset(ext_contact, contact_params)
          contact_id = Repo.update!(changeset).id
          str_contact_id = Integer.to_string(contact_id)
        else
          changeset = Contact.changeset(%Contact{}, contact_params)
          contact_id = Repo.insert!(changeset).id
          str_contact_id = Integer.to_string(contact_id)
        end
      end
      contacts
    end
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
              contact = Repo.get!(Contact,c)
              if contact do
                # untag them
                query = from c in ContactTag,
                  where: c.contact_id == ^contact.id
                tagged = Repo.all(query)
                Repo.delete_all(query)
                # tag them
                query = from tag in Tag,
                  where: tag.id == ^tag.id
                tags = Repo.all(query)
                    changeset = contact
                  |> Repo.preload(:tags) # Load existing data
                  |> Ecto.Changeset.change() # Build the changeset
                  |> Ecto.Changeset.put_assoc(:tags, tags) # Set the association
                Repo.update!(changeset)
                %{status: "200", success: "Contact id #{contact.id} tagged/untagged successfully"}
              else
                %{status: "400", error: "Contact id #{c} not found"}
              end
            else
              %{status: "400", error: "Contact id missing"}
            end
          end
          responses
        else
          json conn, %{status: "400", responses: %{"errors" => "Tag id #{tag_id} not found"}}
        end
      else
        json conn, %{status: "400", responses: %{"errors" => "Parameters missing"}}
      end
    end
  end
  
end