defmodule AppWeb.DashboardTest do
  use AppWeb.ChannelCase

  # setup do
  #   {:ok, _, socket} =
  #     socket("user_id", %{some: :assign})
  #     # |> subscribe_and_join(RoomChannel, "live")
  #
  #   {:ok, socket: socket}
  # end

  describe "AppWeb.Dashboard > " do
    # test "hello" do
    #   IO.inspect("hello")
    # end
    test "handle_event/3" do
      socket = %Phoenix.LiveView.Socket{}

      IO.inspect(socket, label: "socket 20")
      AppWeb.Dashboard.handle_event("sent", "", socket)
      # IO.inspect(new_state, label: "new_state 21")
      # conn = get(conn, Routes.sent_path(conn, :index))
      # assert html_response(conn, 200) =~ "Listing Sent"
    end
  end
end
