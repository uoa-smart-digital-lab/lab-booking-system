# ****************************************************************************************************
# Resolve instructions between the items database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.ItemResolver do
  alias Labbookings.Item
  alias Labbookings.Induction
  alias LabbookingsWeb.PersonResolver


  # ------------------------------------------------------------------------------------------------------
  # Fill the item schema, recursively going into the person records as required.
  # ------------------------------------------------------------------------------------------------------
  def fill_item_schema(args) do
    # Get the core item record
    case Item.get_item_by_name(args.name |> String.downcase()) do
      nil -> {:error, :noitem}
      item ->
        # Get the induction persons if asked for
        case Map.get(args, :inductions) do
          nil -> item  # No induction items requested
          _ ->
            # Get the person records from the list of inductions
            persons = get_persons_from_inductions(args.inductions, Induction.get_inductions_by_itemname(args.itemname))
            # Add the array of items to the person record
            item |> Map.put(:inductions, persons)
        end
    end
  end

  # Given a list of induction records, return the persons identified.  The args allow us to pass into the
  # get persons routine the request for what parts of the record in case we are asking for inductions there
  # in which case we might be wanting the item records associated with inductions that that person has.
  defp get_persons_from_inductions(_, nil), do: []
  defp get_persons_from_inductions(_, []), do: []
  defp get_persons_from_inductions(args, [head | tail]) do
    [ PersonResolver.fill_person_schema(args |> Map.put(:upi, head.upi)) | get_persons_from_inductions(args, tail) ]
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all items in the database
  # Anyone can do this, so no need to check sessionid
  # ------------------------------------------------------------------------------------------------------
  def all_items(_root, _args, _info) do
    {:ok, Item.list_items()}
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a single item record given the database ID or item name
  # Anyone can do this, so no need to check sessionid
  # ------------------------------------------------------------------------------------------------------
  def get_item(_root, args_in, info) do
    args = Map.merge(args_in, info.context)
    get_item_by_id_or_name(Map.get(args, :id), Map.get(args, :name))
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a item by ID or item name if it exists
  # Anyone can do this, so no need to check sessionid
  # ------------------------------------------------------------------------------------------------------
  def get_item_by_id_or_name(nil, nil) do
    {:error, :noname}
  end
  def get_item_by_id_or_name(nil, name) do
    case Item.get_item_by_name(name |> String.downcase()) do
      nil -> {:error, :noitem}
      answer -> {:ok, answer}
    end
  end
  def get_item_by_id_or_name(id, _) do
    case Item.get_item(id) do
      nil -> {:error, :noitem}
      answer -> {:ok, answer}
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new item if one with the name doesn't already exist
  # Only admins and powerusers can create new items
  # ------------------------------------------------------------------------------------------------------
  def create_item(_root, args, info) do
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        case Map.get(user, :status) do
          :admin -> do_create_item(args)
          :poweruser -> do_create_item(args)
          _ -> {:error, :notadmin}
        end
    end
  end
  defp do_create_item(args) do
    case Item.get_item_by_name(args.name |> String.downcase()) do
      nil ->
        case Item.create_item( args |> Map.replace(:name, args.name |> String.downcase()) ) do
          {:ok, newItem} -> {:ok, newItem}
          {:error, error} -> {:error, error}
        end
      _ -> {:error, :itemexists}
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Modify an existing item
  # Only admins and powerusers can modify items
  # ------------------------------------------------------------------------------------------------------
  def update_item(_root, args, info) do
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        case Map.get(user, :status) do
          :admin -> do_update_item(args)
          :poweruser -> do_update_item(args)
          _ -> {:error, :notadmin}
        end
    end
  end
  defp do_update_item(args) do
    case Item.get_item_by_name(args.name |> String.downcase()) do
      nil -> {:error, :noitem}
      answer ->
        case Item.update_item(answer, args |> Map.replace(:name, args.name |> String.downcase())) do
          {:ok, item} -> {:ok, item}
          _ -> {:error, :internalerror}
        end
    end
  end
  # ------------------------------------------------------------------------------------------------------


  # ------------------------------------------------------------------------------------------------------
  # Delete a item if it exists
  # Only admins and powerusers can delete items
  # ------------------------------------------------------------------------------------------------------
  def delete_item(_root, args, info) do
    case Map.get(info.context, :user) do
      nil -> {:error, :nosession}
      user ->
        case Map.get(user, :status) do
          :admin -> do_delete_item(args)
          :poweruser -> do_delete_item(args)
          _ -> {:error, :notadmin}
        end
    end
  end
  defp do_delete_item(args) do
    case Item.get_item_by_name(args.name |> String.downcase()) do
      nil -> {:error, :noitem}
      answer ->
        case Item.delete_item(answer) do
          {:ok, result} ->
            # Delete all references to the item from elsewhere.
            Induction.delete_inductions_by_itemname(args.name)
            # Do something about the course reference

            {:ok, result}
          _ ->
            {:error, :internalerror}
        end
    end
  end
  # ------------------------------------------------------------------------------------------------------
end
