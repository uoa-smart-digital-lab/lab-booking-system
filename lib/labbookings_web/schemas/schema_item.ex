defmodule LabbookingsWeb.Schema.Item do
  use Absinthe.Schema.Notation
  require LabbookingsWeb.Schema.Enums

  alias LabbookingsWeb.ItemResolver

  @desc "Item Type"
  enum :itemtype do
    value :free, description: "No induction required, free to use."
    value :induction, description: "Must be inducted to use item."
    value :supervised, description: "Can only be used under supervision."
  end

  # ------------------------------------------------------------------------------------------------------
  # item Schema definition
  # ------------------------------------------------------------------------------------------------------
  object :item do
    field :name, non_null(:string), description: "The unique item name."
    field :image, non_null(:string), description: "An image for the item /images/......"
    field :url, non_null(:string), description: "A link to somewhere with more info, eg in Canvas."
    field :details, non_null(:json), description: "Any other details in JSON format."

    field :cost, non_null(:integer), description: "Cost of using item per time period."
    field :bookable, non_null(:boolean), description: "Whether bookable or not (eg might be being repared)."
    field :access, non_null(:itemtype), description: "The status of the item (FREE, INDUCTION, SUPERVISED)"
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Queries
  # ------------------------------------------------------------------------------------------------------
  object :item_queries do
    # ----------------------------------------------------------------------------------------------------
    @desc "Get all the items"
    # ----------------------------------------------------------------------------------------------------
    field :item_all, non_null(list_of(:item)) do
      resolve(&ItemResolver.all_items/3)
    end

    # ----------------------------------------------------------------------------------------------------
    @desc "Get an item by name"
    # ----------------------------------------------------------------------------------------------------
    field :item_get, :item do
      arg :name, :string
      resolve &ItemResolver.get_item/3
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Mutations
  # ------------------------------------------------------------------------------------------------------
  object :item_mutations do
    # ----------------------------------------------------------------------------------------------------
    @desc "Create a new item"
    # ----------------------------------------------------------------------------------------------------
    field :item_create, :item do
      arg :name, non_null(:string)
      arg :image, non_null(:string)
      arg :url, non_null(:string)
      arg :details, non_null(:json)
      arg :cost, non_null(:integer)
      arg :bookable, non_null(:boolean)
      arg :access, non_null(:itemtype)
      resolve &ItemResolver.create_item/3
    end

    # ----------------------------------------------------------------------------------------------------
    @desc "Update an item"
    # ----------------------------------------------------------------------------------------------------
    field :item_update, :item do
      arg :name, non_null(:string)
      arg :image, :string
      arg :url, :string
      arg :details, :json
      arg :cost, :integer
      arg :bookable, :boolean
      arg :access, :itemtype
      resolve &ItemResolver.update_item/3
    end

    # ----------------------------------------------------------------------------------------------------
    @desc "Delete an item"
    # ----------------------------------------------------------------------------------------------------
    field :item_delete, :item do
      arg :name, non_null(:string)
      resolve &ItemResolver.delete_item/3
    end
  end
  # ------------------------------------------------------------------------------------------------------
end
