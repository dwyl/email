defmodule AppWeb.SentControllerTest do
  use AppWeb.ConnCase

  alias App.Ctx

  @create_attrs %{message_id: "some message_id", request_id: "some request_id", template: "some template"}

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
      assert html_response(conn, 200) =~ "Send a Test Email"
    end
  end

  describe "create sent" do
    test "redirects to dashboard when data is valid", %{conn: conn} do
      params = %{
        "sent" => %{
          "email" => "success@simulator.amazonses.com",
          "name" => "Success",
          "template" => "welcome"
        }
      }
      conn = post(conn, Routes.sent_path(conn, :create), sent: params)
      assert html_response(conn, 302) =~ "redirected"
    end
  end


  test "test /ping endpoint (always returns 200)", %{conn: conn} do
    conn = get(conn, "/api/ping")

    # IO.inspect(conn, label: "conn")
    assert conn.status == 200
  end

  describe "process_sns" do
    test "reject request if no authorization header" do
      conn = build_conn()
         |> AppWeb.SentController.process_sns(nil)

      assert conn.status == 401
    end

    test "reject request if JWT invalid" do
      jwt = "this.fails"
      conn = build_conn()
         |> put_req_header("authorization", "#{jwt}")
         |> AppWeb.SentController.process_sns(nil)

      assert conn.status == 401
    end

    test "processes valid jwt upsert_sent data" do
      json = %{
        "message_id" => "1232017092006798-f0456694-ac24-487b-9467-b79b8ce798f2-000000",
        "status" => "Sent",
        "email" => "amaze@gmail.com",
        "template" => "welcome"
      }

      jwt = App.Token.generate_and_sign!(json)
      # IO.inspect(jwt, label: "jwt")

      conn = build_conn()
         |> put_req_header("authorization", "#{jwt}")
         |> AppWeb.SentController.process_sns(nil)

      assert conn.status == 200
      {:ok, resp} = Jason.decode(conn.resp_body)
      assert Map.get(resp, "id") > 0 # id increases each time test is run
    end
  end

  describe "read_id/2" do
    test "request to /read/:jwt where jwt is nil", %{conn: conn} do
      conn = AppWeb.SentController.render_pixel(conn, %{"jwt" => nil})
      assert conn.status == 401
    end

    test "make invalid request to /read/:jwt", %{conn: conn} do
      conn = get(conn, "/read/invalid.token")
      assert conn.status == 401
    end

    test "reject valid-looking JTW that is in fact invalid", %{conn: conn} do
      conn = get(conn, "/read/looksvalid.but.itsnot")
      assert conn.status == 401
    end

    test "processes valid request to /read/:jwt", %{conn: conn} do
      sent = fixture(:sent)
      jwt = App.Token.generate_and_sign!(%{"id" => sent.id})
      conn = get(conn, "/read/" <> jwt)
      assert conn.status == 200

      sent2 = App.Ctx.get_sent!(sent.id)
      assert sent.id == sent2.id
      # statuts updated so the status_id should NOT match:
      assert sent.status_id !== sent2.status_id
    end
  end
end
