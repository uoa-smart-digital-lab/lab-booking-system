defmodule LabbookingsWeb.Schema.Item do
  use Absinthe.Schema.Notation

  require LabbookingsWeb.Schema.Enums

  alias Labbookings.Induction
  alias Labbookings.Person
  alias Labbookings.Booking
  alias LabbookingsWeb.ItemResolver
  alias LabbookingsWeb.BookingResolver

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

    field :inductions, non_null(list_of(:person)), description: "List of the people the item has been inducted for" do
      resolve fn post, _, _ ->
        batch({__MODULE__, :inducted_people}, post.name, fn batch_results ->
          {:ok, Map.get(batch_results, post.name)}
        end)
      end
    end

    field :bookings, non_null(list_of(:booking)), description: "List of bookings of items the person has booked" do
      resolve fn post, _, _ ->
        batch({__MODULE__, :booked_items}, post.name, fn batch_results ->
          {:ok, Map.get(batch_results, :bookings)}
        end)
      end
    end
  end

  def booked_items(_, []) do %{} end
  def booked_items(_, [itemname | _]) do
    %{:bookings => Booking.get_bookings_by_itemname(itemname)}
  end

  def inducted_people(_, []) do %{} end
  def inducted_people(param, [name | names]) do
    inductions = Induction.get_inductions_by_itemname(name)
    Map.merge(%{name => get_persons_from_inductions(inductions)}, inducted_people(param, names))
  end

  # Given a list of induction records, return the persons identified.
  defp get_persons_from_inductions(nil), do: []
  defp get_persons_from_inductions([]), do: []
  defp get_persons_from_inductions([head | tail]) do
    [ Person.get_person_by_upi(head.upi) | get_persons_from_inductions(tail) ]
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
      arg :name, non_null(:string)
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

    # ----------------------------------------------------------------------------------------------------
    @desc "Book an item"
    # ----------------------------------------------------------------------------------------------------
    field :item_book, :item do
      arg :itemname, non_null(:string)
      arg :upi, non_null(:string)
      arg :starttime, non_null(:datetime)
      arg :endtime, non_null(:datetime)
      arg :details, non_null(:json)
      resolve &BookingResolver.create_booking/3
    end

    # ----------------------------------------------------------------------------------------------------
    @desc "Unbook an item"
    # ----------------------------------------------------------------------------------------------------
    field :item_unbook, :item do
      arg :itemname, non_null(:string)
      arg :upi, non_null(:string)
      arg :starttime, non_null(:datetime)
      arg :endtime, non_null(:datetime)
      resolve &BookingResolver.delete_booking/3
    end

    # ----------------------------------------------------------------------------------------------------
    @desc "Change a booking for an item"
    # ----------------------------------------------------------------------------------------------------
    field :item_changebooking, :item do
      arg :itemname, non_null(:string)
      arg :upi, non_null(:string)
      arg :starttime, non_null(:datetime)
      arg :endtime, non_null(:datetime)
      arg :newstarttime, :datetime
      arg :newendtime, :datetime
      arg :details, :json
      resolve &BookingResolver.update_booking/3
    end
  end
  # ------------------------------------------------------------------------------------------------------
end
