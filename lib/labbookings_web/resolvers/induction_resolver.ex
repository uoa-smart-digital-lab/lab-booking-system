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
    Induction.get_inductions_by_upi_and_itemname(upi, itemname)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Create a new induction
  # ------------------------------------------------------------------------------------------------------
  def create_induction(_root, args_in, _info) do
    args = args_in |> Map.replace(:upi, String.downcase(args_in.upi)) |> Map.replace(:itemname, String.downcase(args_in.itemname))

    case Person.get_person_by_upi(args.upi) do
      nil -> {:error, :upi}
      _person ->
        case Item.get_item_by_name(args.itemname) do
          nil -> {:error, :item}
          _item ->
            Induction.create_induction(args)
            {:ok, Person.get_person_by_upi(args.upi) |> Map.put(:inductions, Induction.get_inductions_by_upi(args.upi))}
        end
    end
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Delete inductions if they exist
  # ------------------------------------------------------------------------------------------------------
  def delete_inductions(_root, args, _info) do
    upi = Map.get(args, :upi) |> String.downcase()
    itemname = Map.get(args, :itemname) |> String.downcase()

    case Induction.get_inductions_by_upi_and_itemname(upi, itemname) do
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
