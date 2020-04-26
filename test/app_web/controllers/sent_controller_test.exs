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
        "email" => "success@simulator.amazonses.com",
        "name" => "Success",
        "template" => "welcome"
      }
      conn = post(conn, Routes.sent_path(conn, :create), sent: params)
      assert html_response(conn, 302) =~ "redirected"
    end
  end

  describe "/api/ping" do
    test "test /ping endpoint returns 401 with invalid JWT", %{conn: conn} do
      conn = get(conn, "/api/ping")
      assert conn.status == 401
    end


    test "test /ping endpoint returns 200 with valid JWT", %{conn: conn} do
      jwt = App.Token.generate_and_sign!(%{}) # no params required
      conn = conn
         |> put_req_header("authorization", "#{jwt}")
         |> get("/api/ping")

      assert Map.get(Jason.decode!(conn.resp_body), "response_time") > 100
      assert conn.status == 200
    end
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

  describe "/api/send" do
    test "request to /send with invalid JWT", %{conn: conn} do
      jwt = "this.fails"
      conn = conn
         |> put_req_header("authorization", "#{jwt}")
         |> post("/api/send")

      assert conn.status == 401
    end

    test "send an email via /api/send", %{conn: conn} do
      payload = %{
        "email" => "success@simulator.amazonses.com",
        "name" => "Super Successful /api/send test",
        "template" => "welcome"
      }
      jwt = App.Token.generate_and_sign!(payload)
      # IO.inspect(jwt)
      conn = conn
         |> put_req_header("authorization", "#{jwt}")
         |> post("/api/send")

      assert conn.status == 200
      json = Jason.decode!(conn.resp_body)
      IO.inspect(json, label: "json test:150")
      assert Map.get(json, "id") > 0
      assert Map.get(json, "email") == Map.get(payload, "email")

    end
  end

  test "test /pixel endpoint returns 200", %{conn: conn} do
    conn = get(conn, "/pixel")
    assert conn.status == 200
  end
end
