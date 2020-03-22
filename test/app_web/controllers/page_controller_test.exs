defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET AppWeb.PageController.index/2", %{conn: conn} do
    response = conn
    |> Phoenix.Controller.put_view(AppWeb.PageView)
    |> AppWeb.PageController.index(%{hell: "world"})

    assert response.resp_body =~ "Welcome to"
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Email Dashboard"
  end

end
