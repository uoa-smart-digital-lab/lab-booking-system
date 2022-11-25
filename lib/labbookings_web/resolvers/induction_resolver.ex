# ****************************************************************************************************
# Resolve instructions between the induction database and GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.InductionResolver do
  alias Labbookings.Item
  alias Labbookings.Person
  alias Labbookings.Induction

  # ------------------------------------------------------------------------------------------------------
  # Get all inductions in the database
  # ------------------------------------------------------------------------------------------------------
  def all_inductions(_root, _args, _info) do
    {:ok, Induction.list_inductions()}
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all inductions for a person
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_upi(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    Induction.get_inductions_by_upi(upi)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all inductions for an item
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_itemname(_root, args, _info) do
    itemname = Map.get(args, :itemname) |> String.downcase()
    Induction.get_inductions_by_itemname(itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Get all inductions for a person and item
  # ------------------------------------------------------------------------------------------------------
  def get_inductions_by_upi_and_itemname(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    itemname = Map.get(args, :itemname) |> String.downcase()
    Induction.get_inductions_by_upi_and_itemname(itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new induction, testing the password, and replacing an existing one for the user if it exists.
  # ------------------------------------------------------------------------------------------------------
  def create_induction(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    itemname = Map.get(args, :itemname) |> String.downcase()

    case Person.get_person_by_upi(upi) do
      nil -> {:error, :upi}
      person ->
        case Item.get_item_by_name(itemname) do
          nil -> {:error, :item}
          item ->
            Induction.create_induction(person, item)
        end
    end

    # case  do
    #   nil -> {:error, :noinduction}
    #   person ->
    #     if Bcrypt.verify_pass(args.password, person.password) do
    #       case Induction.get_induction_by_upi(args.upi |> String.downcase()) do
    #         nil ->
    #           case args |> Map.put(:inductionid, UUID.uuid4()) |> Map.replace(:upi, args.upi |> String.downcase()) |> Induction.create_induction() do
    #             {:ok, result} ->
    #               {:ok, result}
    #             _ ->
    #               {:error, :internalerror}
    #           end
    #         induction ->
    #           case Induction.update_induction(induction, args |> Map.put(:inductionid, UUID.uuid4()) |> Map.replace(:upi, args.upi |> String.downcase())) do
    #             {:ok, result} ->
    #               {:ok, result}
    #             _ ->
    #               {:error, :internalerror}
    #           end
    #       end
    #     else
    #       {:error, :badpassword}
    #     end
    # end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete a induction if it exists
  # ------------------------------------------------------------------------------------------------------
  def delete_induction(_root, _args, info) do
    upi = Map.get(args, :upi) |> String.downcase()
    itemname = Map.get(args, :itemname) |> String.downcase()

    case Induction.get_inductions_by_upi_and_itemname(upi, inductionid) do
      inductions ->
        delete_all_inductions(inductions)
        {:ok, inductions}
    end
  end

  defp delete_all_inductions([]) do
    :ok
  end
  defp delete_all_inductions([induction | rest]) do
    Induction.delete_induction(induction)
    delete_all_inductions(rest)
  end
  # ------------------------------------------------------------------------------------------------------
end
