defmodule AppWeb.Dashboard do
  use Phoenix.LiveView

    @topic "live"

    def mount(_session, _params, socket) do
      AppWeb.Endpoint.subscribe(@topic) # subscribe to the channel
      sent = App.Ctx.list_sent_with_status()
      # IO.inspect(sent, label: "sent")
      {:ok, assign(socket, %{val: 0, sent: sent}),
        layout: {AppWeb.LayoutView, "live.html"}}
    end

    def handle_event("sent", _value, socket) do
      # IO.inspect(socket, label: "socket")
      new_state = update(socket, :sent, App.Ctx.list_sent_with_status())
      # IO.inspect(socket, label: "socket")
      # new_state = update(socket, :sent, sent)
      AppWeb.Endpoint.broadcast_from(self(), @topic, "sent", new_state.assigns)
      {:noreply, new_state}
    end

    def handle_info(_msg, socket) do
      {:noreply, assign(socket, sent: App.Ctx.list_sent_with_status())}
    end

    def render(assigns) do
      AppWeb.PageView.render("dashboard.html", assigns)
    end
end
