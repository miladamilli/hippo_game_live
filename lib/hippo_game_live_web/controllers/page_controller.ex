defmodule HippoGameLiveWeb.PageController do
  use HippoGameLiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      HippoGameLiveWeb.HippoGameLive,
      session: %{cookies: conn.cookies}
    )
  end
end
