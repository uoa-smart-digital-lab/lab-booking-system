defmodule LabbookingsWeb.Schema.Person do
  use Absinthe.Schema.Notation

  alias Labbookings.Induction
  alias Labbookings.Item
  alias Labbookings.Person
  alias Labbookings.Booking

  alias LabbookingsWeb.PersonResolver
  alias LabbookingsWeb.SessionResolver
  alias LabbookingsWeb.InductionResolver

  @desc "User Type"
  enum :usertype do
    value :user, description: "Ordinary User"
    value :poweruser, description: "Power User"
    value :admin, description: "Administrator"
  end

  # ------------------------------------------------------------------------------------------------------
  # Person Schema Definition
  # ------------------------------------------------------------------------------------------------------
  object :person do
    field :name, non_null(:string), description: "The person's name"
    field :upi, non_null(:string), description: "The University of Auckland Universal Personal Identifier (UPI)"
    field :password, non_null(:string)
    field :status, non_null(:usertype), description: "The usertype of the person, eg ADMIN, POWERUSER or USER"
    field :details, non_null(:json), description: "Any other details in JSON format"
    field :tokens, non_null(:integer), description: "Number of tokens in the account"

    field :inductions, non_null(list_of(:item)), description: "List of items the person is inducted for" do
      resolve fn post, _, _ ->
        batch({__MODULE__, :inducted_items}, post.upi, fn batch_results ->
          {:ok, Map.get(batch_results, post.upi)}
        end)
      end
    end

    field :bookings, non_null(list_of(:booking)), description: "List of bookings of items the person has booked" do
      resolve fn post, _, _ ->
        batch({__MODULE__, :booked_items, %{starttime: get_parameter(post, :starttime), endtime: get_parameter(post, :endtime)}}, post.upi, fn batch_results ->
          {:ok, Map.get(batch_results, post.upi)}
        end)
      end
    end
  end

  def get_parameter(conn, param) do
    case Map.get(conn, :__args__) do
      nil -> nil
      args -> Map.get(args, param)
    end
  end

  def booked_items(_, []) do %{} end
  def booked_items(param, [upi | upis]) do
    Map.merge(%{upi => Booking.get_bookings_by_upi(upi, param.starttime, param.endtime)}, booked_items(param, upis))
  end

  def inducted_items(_, []) do %{} end
  def inducted_items(param, [upi | upis]) do
    Map.merge(%{upi => get_items_from_inductions(Induction.get_inductions_by_upi(upi))}, inducted_items(param, upis))
  end

  # Given a list of induction records, return the items identified.
  defp get_items_from_inductions(nil), do: []
  defp get_items_from_inductions([]), do: []
  defp get_items_from_inductions([head | tail]) do
    [ Item.get_item_by_name(head.itemname) | get_items_from_inductions(tail) ]
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Session Schema Definition
  # ------------------------------------------------------------------------------------------------------
  object :session do
    field :sessionid, non_null(:string)
    field :person, non_null(:person) do
      resolve fn post, _, resolution ->
        batch({__MODULE__, :people, resolution.context.user}, post.upi, fn batch_results ->
          {:ok, Map.get(batch_results, post.upi)}
        end)
      end
    end
  end

  def people(_, []) do %{} end
  def people(user, [upi | upis]) do
    Map.merge(%{upi => Person.get_person_by_upi(upi) |> PersonResolver.tune_for_user(user) }, people(user, upis))
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Queries
  # ------------------------------------------------------------------------------------------------------
  object :person_queries do
    # ----------------------------------------------------------------------------------------------------
    @desc "Get all the people"
    # ----------------------------------------------------------------------------------------------------
    field :person_all, non_null(list_of(:person)) do
      resolve(&PersonResolver.all_people/3)
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Get a person by UPI"
    # ----------------------------------------------------------------------------------------------------
    field :person_get, :person do
      arg :upi, non_null(:string)

      resolve &PersonResolver.get_person/3
    end
    # ----------------------------------------------------------------------------------------------------
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Mutations
  # ------------------------------------------------------------------------------------------------------
  object :person_mutations do
    # ----------------------------------------------------------------------------------------------------
    @desc "Create a new person"
    # ----------------------------------------------------------------------------------------------------
    field :person_create, :person do
      arg :upi, non_null(:string)
      arg :name, non_null(:string)
      arg :password, non_null(:string)
      arg :status, non_null(:usertype)
      arg :details, non_null(:json)
      resolve &PersonResolver.create_person/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Update a person"
    # ----------------------------------------------------------------------------------------------------
    field :person_update, :person do
      arg :upi, non_null(:string)
      arg :name, :string
      arg :password, :string
      arg :status, :usertype
      arg :details, :json
      resolve &PersonResolver.update_person/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Delete a person"
    # ----------------------------------------------------------------------------------------------------
    field :person_delete, :person do
      arg :upi, non_null(:string)
      resolve &PersonResolver.delete_person/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Log in"
    # ----------------------------------------------------------------------------------------------------
    field :login, :session do
      arg :upi, non_null(:string)
      arg :password, non_null(:string)
      resolve &SessionResolver.create_session/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Log out"
    # ----------------------------------------------------------------------------------------------------
    field :logout, :session do
      resolve &SessionResolver.delete_session/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Induct a person"
    # ----------------------------------------------------------------------------------------------------
    field :person_induct, :person do
      arg :upi, non_null(:string)
      arg :itemname, non_null(:string)
      resolve &InductionResolver.create_induction/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Uninduct a person"
    # ----------------------------------------------------------------------------------------------------
    field :person_uninduct, :person do
      arg :upi, non_null(:string)
      arg :itemname, non_null(:string)
      resolve &InductionResolver.delete_induction/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Adjust the number of tokens"
    # ----------------------------------------------------------------------------------------------------
    field :person_adjusttokens, :person do
      arg :upi, non_null(:string)
      arg :tokens, non_null(:integer)
      resolve &PersonResolver.adjust_tokens/3
    end
    # ----------------------------------------------------------------------------------------------------
  end
  # ------------------------------------------------------------------------------------------------------
end
