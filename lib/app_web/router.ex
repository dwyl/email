defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    # get "/", PageController, :index
    live("/", Dashboard)
    resources "/sent", SentController
    get "/_version", GithubVersionController, :index # for deployment versioning
  end

  # Other scopes may use custom stacks.
  scope "/api", AppWeb do
    pipe_through :api
    get "/hello", SentController, :hello
    post "/sns", SentController, :process_jwt
  end
end
