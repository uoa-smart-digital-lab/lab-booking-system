defmodule LabbookingsWeb.Schema do
  use Absinthe.Schema

  import_types Labbookings.Schema.Types.Custom.JSON
  import_types Absinthe.Type.Custom
  import_types LabbookingsWeb.Schema.Person

  query do
    import_fields :person_queries
  end

  mutation do
    import_fields :person_mutations
  end

end
