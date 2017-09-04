defmodule CercleApi.APIV2.BulkController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Contact, Organization, Tag, ContactTag}

  plug CercleApi.Plug.EnsureAuthenticated

  def bulk_contact_create(conn, %{"items" => items, "return" => return}) do
    if Enum.count(items) > 100 do
      json conn, %{status: 422, error_message: "Maximum 100 records are permitted per call"}
    else
      user = CercleApi.Plug.current_user(conn)
      company = current_company(conn, user)
      contacts = for item <- items do
        contact_params = Map.put(item["contact"], "user_id", user.id) |> Map.put("company_id", company.id)

        if contact_params["full_name"] do
          [first_name|splits] = String.split(contact_params["full_name"], ~r/\s+/)
          last_name = Enum.join(splits, " ")

          contact_params = contact_params
          |> Map.put("first_name", first_name)
          |> Map.put("last_name", last_name)
        end

        organization_params = Map.put(item["organization"], "company_id", company.id)

        if organization_params["id"] do
          ext_org = Repo.get_by(Organization, id: organization_params["id"], company_id: company.id)
        end

        if ext_org do
          contact_params = Map.put(contact_params, "organization_id", ext_org.id)
        else
          changeset = Organization.changeset(%Organization{}, organization_params)
          organization = Repo.insert!(changeset)
          contact_params = Map.put(contact_params, "organization_id", organization.id)
        end

        if contact_params["id"] do
          ext_contact = Repo.get_by(Contact, id: contact_params["id"], company_id: company.id)
        else contact_params["email"]
          ext_contact = Repo.get_by(Contact, email: contact_params["email"], company_id: company.id)
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
      if return do
        contacts
      else
        json conn, %{status: 200, contacts: contacts}
      end
    end
  end

  def bulk_tag_or_untag_contacts(conn, %{"contacts" => contacts, "tag_id" => tag_id, "untag" => untag, "return" => return}) do
    responses = []
    if contacts && Enum.count(contacts) > 100 do
      json conn, %{status: 422, error_message: "Maximum 100 records are permitted per call"}
    else
      if tag_id && untag != nil do
        {tag_id, _rest} = Integer.parse(tag_id)
        tag = Repo.get(Tag, tag_id)
        if tag do
          user = CercleApi.Plug.current_user(conn)
          responses = for c <- contacts do
            if c do
              {contact_id, _rest} = Integer.parse(c)
              contact = Repo.get(Contact, contact_id)

              if contact do
                contact = Repo.preload(contact, [:tags])
                query = from c in ContactTag,
                  where: c.contact_id == ^contact.id and c.tag_id == ^tag_id
                tagged = Repo.all(query)

                # untag contact
                if untag == true && tagged do
                  Repo.delete_all(query)
                end

                tag_ids = Enum.map(contact.tags, fn(t) -> t.id end)
                all_tag_ids = tag_ids ++ [tag.id]
                #tag contact
                if untag == false && Enum.count(tagged) == 0 do
                  query = from tag in Tag,
                  where: tag.id in ^all_tag_ids
                  tags = Repo.all(query)
                      changeset = contact
                    |> Repo.preload(:tags) # Load existing data
                    |> Ecto.Changeset.change() # Build the changeset
                    |> Ecto.Changeset.put_assoc(:tags, tags) # Set the association
                  Repo.update!(changeset)
                end

                %{status: 200, success: "Contact id #{contact.id} tagged/untagged successfully"}
              else
                %{status: 400, error: "Contact id #{c} not found"}
              end
            else
              %{status: 400, error: "Contact id missing"}
            end
          end
          if return do
            contacts
          else
            json conn, %{status: 200, responses: responses}
          end

        else
          json conn, %{status: 400, responses: %{"errors" => "Tag id #{tag_id} not found"}}
        end
      else
        json conn, %{status: 400, responses: %{"errors" => "Parameters missing"}}
      end
    end
  end

end
