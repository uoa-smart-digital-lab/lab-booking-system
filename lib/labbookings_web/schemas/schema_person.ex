defmodule LabbookingsWeb.Schema.Person do
  use Absinthe.Schema.Notation

  alias LabbookingsWeb.PersonResolver
  alias LabbookingsWeb.SessionResolver

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
    field :details, :json, description: "Any other details in JSON format"
  end
  # ------------------------------------------------------------------------------------------------------

  # ------------------------------------------------------------------------------------------------------
  # Session Schema Definition
  # ------------------------------------------------------------------------------------------------------
  object :session do
    field :sessionid, :string
    field :upi, non_null(:string)
  end
  # ------------------------------------------------------------------------------------------------------



  # ------------------------------------------------------------------------------------------------------
  # Queries
  # ------------------------------------------------------------------------------------------------------
  object :person_queries do
    # ----------------------------------------------------------------------------------------------------
    @desc "Get all the people"
    # ----------------------------------------------------------------------------------------------------
    field :all_people, non_null(list_of(:person)) do
      resolve(&PersonResolver.all_people/3)
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Get a person by UPI"
    # ----------------------------------------------------------------------------------------------------
    field :get_person, :person do
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
    field :create_person, :person do
      arg :upi, non_null(:string)
      arg :name, non_null(:string)
      arg :password, non_null(:string)
      arg :status, non_null(:usertype)
      arg :details, :json
      resolve &PersonResolver.create_person/3
    end
    # ----------------------------------------------------------------------------------------------------

    # ----------------------------------------------------------------------------------------------------
    @desc "Update a person"
    # ----------------------------------------------------------------------------------------------------
    field :update_person, :person do
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
    field :delete_person, :person do
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
  end
  # ------------------------------------------------------------------------------------------------------
end
