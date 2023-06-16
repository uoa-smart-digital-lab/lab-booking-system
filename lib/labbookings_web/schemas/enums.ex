# ****************************************************************************************************
# A set of helper functions to make it easier to convert between integers stored in the database and
# the atom-based representations of enums used for GraphQL
# ****************************************************************************************************
defmodule LabbookingsWeb.Schema.Enums do
  # ----------------------------------------------------------------------------------------------------
  # Public Interface
  # ----------------------------------------------------------------------------------------------------
  defp enums() do
    %{
      access: [:free, :induction, :supervised],
      status: [:user, :poweruser, :admin]
    }
  end

  # Converts either a map or a list of maps such that the named key is switched between integer and atom so that it can
  # be stored as the integer in the database, but expressed as an atom (and ultimately a string) through graphql
  def convert(nil, _), do: nil
  def convert({:ok, the_map}, the_key) when is_map(the_map), do: {:ok, the_map |> Map.replace(the_key, convert_item(Map.get(the_map, the_key), Map.get(enums(), the_key)))}
  def convert({:ok, data}, _), do: {:ok, data}
  def convert({:error, error}, _), do: {:error, error}
  def convert(the_list, the_key) when is_list(the_list), do: convert_list(the_list, Map.get(enums(), the_key), the_key)
  def convert(the_map, the_key) when is_map(the_map), do: the_map |> Map.replace(the_key, convert_item(Map.get(the_map, the_key), Map.get(enums(), the_key)))
  def convert(the_map, _), do: the_map
  # ----------------------------------------------------------------------------------------------------


  # ----------------------------------------------------------------------------------------------------
  # Private Functions
  # ----------------------------------------------------------------------------------------------------
  # Convert between atom and integer, depending on what is passed in.  Reference determines the specific
  # enum list to use.  If the atom or index doesn't exist, the first of the list is used as default, or 0.
  defp convert_item(the_atom, reference) when is_atom(the_atom), do: get_index(reference, the_atom, 0, 0)
  defp convert_item(the_index, reference) when is_integer(the_index) do
    case get_atom(reference, the_index) do
      :error ->
        [head | _] = reference
        head
        the_atom -> the_atom
    end
  end

  # Convert a list of maps
  defp convert_list([], _, _), do: []
  defp convert_list([head | tail], reference, the_key) do
    converted_value = head |> Map.get(the_key) |> convert_item(reference)
    [ head |> Map.replace(the_key, converted_value) | convert_list(tail, reference, the_key)]
  end

  # Given a reference list and an index, return the approprate atom, or the default value if out of range
  defp get_index([], _, _, default), do: default
  defp get_index([head | _], head, count, _), do: count
  defp get_index([_ | tail], item, count, default), do: get_index(tail, item, count+1, default)

  # Given a reference list and an atom, return the index position of that atom or :error if it doesn't exist.
  # The list is assumed to be numbered from 0
  defp get_atom([], _), do: :error
  defp get_atom([head | _], 0), do: head
  defp get_atom([_ | tail], index), do: get_atom(tail, index-1)
  # ----------------------------------------------------------------------------------------------------
end
