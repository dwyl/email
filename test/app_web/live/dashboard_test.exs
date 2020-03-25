defmodule AppWeb.DashboardTest do
  use AppWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "AppWeb.Dashboard > " do
    test "handle_event/3", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      assert view.module == AppWeb.Dashboard
      assert html =~ "Email"
      send(view.pid, %{refresh: 1})
      Process.exit(view.pid, :kill)
    end
  end
end
