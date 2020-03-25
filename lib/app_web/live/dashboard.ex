defmodule AppWeb.Dashboard do
  use Phoenix.LiveView
  @topic "live"

  def mount(_session, _params, socket) do
    AppWeb.Endpoint.subscribe(@topic) # subscribe to the channel
    sent = App.Ctx.list_sent_with_status()
    {:ok, assign(socket, %{sent: sent}),
      layout: {AppWeb.LayoutView, "live.html"}}
  end

  def handle_info(_msg, socket) do
    {:noreply, assign(socket, sent: App.Ctx.list_sent_with_status())}
  end

  def render(assigns) do
    AppWeb.PageView.render("dashboard.html", assigns)
  end
end
