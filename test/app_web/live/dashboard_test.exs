defmodule AppWeb.DashboardTest do
  use AppWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "AppWeb.Dashboard > " do
    test "handle_event/3", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      IO.inspect(view, label: "view")
      assert html =~ "Email"
      # result = render_click(view, "refresh")
      # IO.inspect(result, label: "result")
      # assert render_click(view, "refresh") =~ "Status"
      # socket = %Phoenix.LiveView.Socket{assigns: %{sent: []}}
      # AppWeb.Dashboard.handle_event("sent", "", socket)
    end
  end
end
