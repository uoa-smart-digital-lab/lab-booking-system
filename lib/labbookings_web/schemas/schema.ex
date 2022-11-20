defmodule LabbookingsWeb.Schema do
  use Absinthe.Schema

  import_types Labbookings.Schema.Types.Custom.JSON
  import_types Absinthe.Type.Custom
  import_types LabbookingsWeb.Schema.Person
  import_types LabbookingsWeb.Schema.Item

  query do
    import_fields :person_queries
    import_fields :item_queries
  end

  mutation do
    import_fields :person_mutations
    import_fields :item_mutations
  end

end
