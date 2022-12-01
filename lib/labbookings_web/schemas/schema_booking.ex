defmodule LabbookingsWeb.Schema.Booking do
  use Absinthe.Schema.Notation

  require LabbookingsWeb.Schema.Enums

  alias Labbookings.Person
  alias Labbookings.Item
  alias LabbookingsWeb.PersonResolver

  # ------------------------------------------------------------------------------------------------------
  # Bookings Schema definition
  # ------------------------------------------------------------------------------------------------------
  object :booking do
    field :item, non_null(:item), description: "The item being booked." do
      resolve fn post, _, _ ->
        batch({__MODULE__, :items}, post.itemname, fn batch_results ->
          {:ok, Map.get(batch_results, post.itemname)}
        end)
      end
    end

    field :person, non_null(:person), description: "The person the item is booked for" do
      resolve fn post, _, _ ->
        batch({__MODULE__, :people}, post.upi, fn batch_results ->
          {:ok, Map.get(batch_results, post.upi)}
        end)
      end
    end

    field :details, non_null(:json), description: "Details about the booking"

    field :starttime, non_null(:datetime), description: "Starting time"
    field :endtime, non_null(:datetime), description: "Ending time"
  end

  def people(_, []) do %{} end
  def people(user, [upi | upis]) do
    Map.merge(%{upi => Person.get_person_by_upi(upi) |> PersonResolver.tune_for_user(user) }, people(user, upis))
  end

  def items(_, []) do %{} end
  def items(param, [name | names]) do
    Map.merge(%{name => Item.get_item_by_name(name)}, items(param, names))
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Queries
  # ------------------------------------------------------------------------------------------------------
  object :booking_queries do
    # Nothing here - bookings are found through the items and persons queries.
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Mutations
  # ------------------------------------------------------------------------------------------------------
  object :booking_mutations do
    # Nothing here - bookings are made as part of the items mutations.
  end
  # ------------------------------------------------------------------------------------------------------
end
