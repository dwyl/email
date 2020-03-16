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

    def handle_event("inc", _value, socket) do
      # sent = App.Ctx.list_sent()

      IO.inspect(socket, label: "socket")
      new_state = update(socket, :val, &(&1 + 1))
      IO.inspect(socket, label: "socket")
      # new_state = update(socket, :sent, sent)
      AppWeb.Endpoint.broadcast_from(self(), @topic, "inc", new_state.assigns)
      {:noreply, new_state}
    end

    def handle_event("dec", _, socket) do
      # sent = App.Ctx.list_sent()

      new_state = update(socket, :val, &(&1 - 1))
      AppWeb.Endpoint.broadcast_from(self(), @topic, "dec", new_state.assigns)
      {:noreply, new_state}
    end

    def handle_info(msg, socket) do
      {:noreply, assign(socket, val: msg.payload.val)}
    end

    def render(assigns) do
      AppWeb.PageView.render("dashboard.html", assigns)
    end
end
