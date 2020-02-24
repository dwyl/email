defmodule AppWeb.SentControllerTest do
  use AppWeb.ConnCase

  alias App.Ctx

  @create_attrs %{message_id: "some message_id", request_id: "some request_id", template: "some template"}
  @update_attrs %{message_id: "some updated message_id", request_id: "some updated request_id", template: "some updated template"}
  @invalid_attrs %{message_id: nil, request_id: nil, template: nil}

  def fixture(:sent) do
    {:ok, sent} = Ctx.create_sent(@create_attrs)
    sent
  end

  describe "index" do
    test "lists all sent", %{conn: conn} do
      conn = get(conn, Routes.sent_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Sent"
    end
  end

  describe "new sent" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.sent_path(conn, :new))
      assert html_response(conn, 200) =~ "New Sent"
    end
  end

  describe "create sent" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.sent_path(conn, :create), sent: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.sent_path(conn, :show, id)

      conn = get(conn, Routes.sent_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Sent"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.sent_path(conn, :create), sent: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Sent"
    end
  end

  describe "edit sent" do
    setup [:create_sent]

    test "renders form for editing chosen sent", %{conn: conn, sent: sent} do
      conn = get(conn, Routes.sent_path(conn, :edit, sent))
      assert html_response(conn, 200) =~ "Edit Sent"
    end
  end

  describe "update sent" do
    setup [:create_sent]

    test "redirects when data is valid", %{conn: conn, sent: sent} do
      conn = put(conn, Routes.sent_path(conn, :update, sent), sent: @update_attrs)
      assert redirected_to(conn) == Routes.sent_path(conn, :show, sent)

      conn = get(conn, Routes.sent_path(conn, :show, sent))
      assert html_response(conn, 200) =~ "some updated message_id"
    end

    test "renders errors when data is invalid", %{conn: conn, sent: sent} do
      conn = put(conn, Routes.sent_path(conn, :update, sent), sent: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Sent"
    end
  end

  describe "delete sent" do
    setup [:create_sent]

    test "deletes chosen sent", %{conn: conn, sent: sent} do
      conn = delete(conn, Routes.sent_path(conn, :delete, sent))
      assert redirected_to(conn) == Routes.sent_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.sent_path(conn, :show, sent))
      end
    end
  end

  defp create_sent(_) do
    sent = fixture(:sent)
    {:ok, sent: sent}
  end
end
