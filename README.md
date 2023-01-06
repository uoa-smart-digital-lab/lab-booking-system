# Lab Booking System

Note, this is still very much a work-in-progress, so there are no easy installation how-tos yet.  If you want to try this out in its current raw form, you have to first set up you development environment for Elixir and the Phoenix Framework.

The [Phoenix Framework Installation page](https://hexdocs.pm/phoenix/installation.html) is a good place to start.
In particular, you will need to set up postgresql, and set the login password in the config file dev.exs of this code to whatever you choose.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

To setup and build the Svelte WebApps:

  * Ensure that yarn is install (https://yarnpkg.com) 
  * cd into the main directory for each Svelte App (priv/static/[Svelte App])
  * The first time, run `yarn` to set up the libraries.
  * To build the development release, use `yarn build`

For the server to serve the static files from the right place, links have to be created to the build folders:
  * cd into the build folder, then
  * ln -s ../[Svelte App]/dist ./[Svelte App]  eg ln -s ../admin/dist ./admin

Now you can visit [`https://[URL]:3001`](https://[URL]:3001) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
