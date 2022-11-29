defmodule LabbookingsWeb.Schema.Booking do
  use Absinthe.Schema.Notation

  require LabbookingsWeb.Schema.Enums

  alias Labbookings.Person
  alias Labbookings.Item
  # alias LabbookingsWeb.BookingResolver

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
  def people(param, [upi | upis]) do
    person = Person.get_person_by_upi(upi)
    Map.merge(%{upi => person}, people(param, upis))
  end

  def items(_, []) do %{} end
  def items(param, [name | names]) do
    item = Item.get_item_by_name(name)
    Map.merge(%{name => item}, items(param, names))
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Queries
  # ------------------------------------------------------------------------------------------------------
  object :booking_queries do
    # # ----------------------------------------------------------------------------------------------------
    # @desc "Get all the bookings"
    # # ----------------------------------------------------------------------------------------------------
    # field :booking_all, non_null(list_of(:booking)) do
    #   resolve(&BookingResolver.all_bookings/3)
    # end

    # # ----------------------------------------------------------------------------------------------------
    # @desc "Get a booking"
    # # ----------------------------------------------------------------------------------------------------
    # field :booking_get, :booking do
    #   arg :itemname, non_null(:string)
    #   arg :upi, non_null(:string)
    #   arg :starttime, non_null(:datetime)
    #   arg :endtime, non_null(:datetime)
    #   resolve &BookingResolver.get_bookings_by_itemname_and_date/3
    # end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Mutations
  # ------------------------------------------------------------------------------------------------------
  object :booking_mutations do
    # # ----------------------------------------------------------------------------------------------------
    # @desc "Create a new booking"
    # # ----------------------------------------------------------------------------------------------------
    # field :booking_create, :booking do
    #   arg :itemname, non_null(:string)
    #   arg :upi, non_null(:string)
    #   arg :details, non_null(:json)
    #   arg :starttime, non_null(:datetime)
    #   arg :endtime, non_null(:datetime)
    #   resolve &BookingResolver.create_booking/3
    # end

    # # ----------------------------------------------------------------------------------------------------
    # @desc "Update a booking"
    # # ----------------------------------------------------------------------------------------------------
    # field :booking_update, :item do
    #   arg :itemname, non_null(:string)
    #   arg :upi, non_null(:string)
    #   arg :starttime, non_null(:datetime)
    #   arg :endtime, non_null(:datetime)

    #   arg :details, :json
    #   arg :newstarttime, :datetime
    #   arg :newendtime, :datetime

    #   resolve &BookingResolver.update_booking/3
    # end

    # # ----------------------------------------------------------------------------------------------------
    # @desc "Delete a booking"
    # # ----------------------------------------------------------------------------------------------------
    # field :booking_delete, :item do
    #   arg :itemname, non_null(:string)
    #   arg :upi, non_null(:string)
    #   arg :starttime, non_null(:datetime)
    #   arg :endtime, non_null(:datetime)
    #   resolve &BookingResolver.delete_booking/3
    # end
  end
  # ------------------------------------------------------------------------------------------------------
end
