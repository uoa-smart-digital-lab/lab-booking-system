defmodule LabbookingsWeb.Schema.Booking do
  use Absinthe.Schema.Notation

  require LabbookingsWeb.Schema.Enums

  alias Labbookings.Person
  alias Labbookings.Item

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
      resolve fn post, _, resolution ->
        batch({__MODULE__, :people}, post.upi, fn batch_results ->
          case send_person_if_allowed(resolution.context.user, Map.get(batch_results, post.upi)) do
            {:ok, person} -> {:ok, person}
            error -> error
          end
        end)
      end
    end

    field :details, non_null(:json), description: "Details about the booking"

    field :starttime, non_null(:datetime), description: "Starting time"
    field :endtime, non_null(:datetime), description: "Ending time"
  end

  def people(_, []) do %{} end
  def people(param, [upi | upis]) do
    IO.inspect param
    person = Person.get_person_by_upi(upi)
    Map.merge(%{upi => person |> Map.replace(:password, "") }, people(param, upis))
  end

  def items(_, []) do %{} end
  def items(param, [name | names]) do
    item = Item.get_item_by_name(name)
    Map.merge(%{name => item}, items(param, names))
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Either the person is admin or poweruser, or the person upi matches the sessionid upi
  # ------------------------------------------------------------------------------------------------------
  def send_person_if_allowed(nil, _), do: {:error, :nosession}
  def send_person_if_allowed(user, person) do
    if user.upi == person.upi do
      {:ok, person}
    else
      case Map.get(user, :status) do
        :admin -> {:ok, person}
        :poweruser -> {:ok, person}
        _ -> {:error, :notadmin}
      end
    end
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
