# Lab Booking System

Note, this is still very much a work-in-progress, so there are no easy installation how-tos yet.  If you want to try this out in its current raw form, you have to first set up you development environment for Elixir and the Phoenix Framework.

The [Phoenix Framework Installation page](https://hexdocs.pm/phoenix/installation.html) is a good place to start.
In particular, you will need to set up postgresql, and set the login password in the config file dev.exs of this code to whatever you choose.

## Prerequisites
  * Install postgreqel

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

To setup and build the React WebApps:

  * Ensure that npm is install (eg `sudo apt-get install npm`) 
  * cd into the main directory for each React App (priv/static/[React App])
  * ensure that react-scripts is installed (eg `npm install react-scripts`)
  * There will be other packages requiring installation, but each you try building, it will show what is missing.
  * To build the development release, use `npm run build` or `yarn build`

  * Note there is an issue with reactscripts that the following command should fix:
    * sed -i 's/;;/;/g' ./node_modules/semantic-ui-css/semantic.min.css

For the server to serve the static files from the right place, either links have to be created to the build folders or the build folders have to copied in under the priv/static/builds folder

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
