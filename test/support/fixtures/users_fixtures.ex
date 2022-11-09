defmodule Labbookings.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Labbookings.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        description: "some description",
        upi: "some upi"
      })
      |> Labbookings.Users.create_user()

    user
  end

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        description: "some description",
        group: "some group",
        upi: "some upi"
      })
      |> Labbookings.Users.create_user()

    user
  end
end
