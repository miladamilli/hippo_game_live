defmodule HippoGameLiveWeb.Router do
  use HippoGameLiveWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # plug :put_layout, {HippoGameLiveWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HippoGameLiveWeb do
    pipe_through :browser

    # get "/", PageController, :index
    # live "/", HippoGameLive
    get "/", PageController, :game
  end

  # Other scopes may use custom stacks.
  # scope "/api", HippoGameLiveWeb do
  #   pipe_through :api
  # end
end
