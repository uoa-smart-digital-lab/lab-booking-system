defmodule Labbookings.UsersTest do
  use Labbookings.DataCase

  alias Labbookings.Users

  describe "users" do
    alias Labbookings.Users.User

    import Labbookings.UsersFixtures

    @invalid_attrs %{description: nil, upi: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{description: "some description", upi: "some upi"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.description == "some description"
      assert user.upi == "some upi"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{description: "some updated description", upi: "some updated upi"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.description == "some updated description"
      assert user.upi == "some updated upi"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  describe "users" do
    alias Labbookings.Users.User

    import Labbookings.UsersFixtures

    @invalid_attrs %{description: nil, group: nil, upi: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{description: "some description", group: "some group", upi: "some upi"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.description == "some description"
      assert user.group == "some group"
      assert user.upi == "some upi"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{description: "some updated description", group: "some updated group", upi: "some updated upi"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.description == "some updated description"
      assert user.group == "some updated group"
      assert user.upi == "some updated upi"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
