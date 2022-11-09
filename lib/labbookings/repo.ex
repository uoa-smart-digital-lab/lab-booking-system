defmodule Labbookings.Repo do
  use Ecto.Repo,
    otp_app: :labbookings,
    adapter: Ecto.Adapters.Postgres
end
