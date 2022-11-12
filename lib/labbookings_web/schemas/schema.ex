defmodule LabbookingsWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Type.Custom
  import_types LabbookingsWeb.Schema.Person
  import_types Labbookings.Schema.Types.Custom.JSON

  query do
    import_fields :person_queries
  end

  mutation do
    import_fields :person_mutations
  end

end
