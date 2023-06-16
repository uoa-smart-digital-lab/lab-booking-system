# ****************************************************************************************************
# Resolve instructions between the items database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.ItemResolver do
  alias Labbookings.Item
  alias Labbookings.Induction


  # ------------------------------------------------------------------------------------------------------
  # Get all items in the database
  # Anyone can do this, so no need to check sessionid
  # ------------------------------------------------------------------------------------------------------
  def all_items(_root, args_in, info) do
    args = Map.merge(args_in, info.context)
    {:ok, Item.list_items() |> add_args(args)}
  end

  defp add_args([], _), do: []
  defp add_args([head | tail], args), do: [head |> Map.merge(%{__args__: args}) | add_args(tail, args)]
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get a single item record given the database ID or item name
  # Anyone can do this, so no need to check sessionid
  # ------------------------------------------------------------------------------------------------------
  def get_item(_root, args_in, info) do
    args = Map.merge(args_in, info.context)
    case Item.get_item_by_name(Map.get(args, :name) |> String.downcase()) do
      nil -> {:error, :noitem}
      answer -> {:ok, answer |> Map.merge(%{__args__: args})}
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
