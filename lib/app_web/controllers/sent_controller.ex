defmodule AppWeb.SentController do
  use AppWeb, :controller

  alias App.Ctx
  alias App.Ctx.Sent

  def index(conn, _params) do
    sent = Ctx.list_sent()
    render(conn, "index.html", sent: sent)
  end

  def new(conn, _params) do
    changeset = Ctx.change_sent(%Sent{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sent" => sent_params}) do
    case Ctx.create_sent(sent_params) do
      {:ok, sent} ->
        conn
        |> put_flash(:info, "Sent created successfully.")
        |> redirect(to: Routes.sent_path(conn, :show, sent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sent = Ctx.get_sent!(id)
    render(conn, "show.html", sent: sent)
  end

  def edit(conn, %{"id" => id}) do
    sent = Ctx.get_sent!(id)
    changeset = Ctx.change_sent(sent)
    render(conn, "edit.html", sent: sent, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sent" => sent_params}) do
    sent = Ctx.get_sent!(id)

    case Ctx.update_sent(sent, sent_params) do
      {:ok, sent} ->
        conn
        |> put_flash(:info, "Sent updated successfully.")
        |> redirect(to: Routes.sent_path(conn, :show, sent))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sent: sent, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sent = Ctx.get_sent!(id)
    {:ok, _sent} = Ctx.delete_sent(sent)

    conn
    |> put_flash(:info, "Sent deleted successfully.")
    |> redirect(to: Routes.sent_path(conn, :index))
  end

  def hello(conn, _params) do
    data = %{"hello" => "world"}
    conn
    |> put_resp_header("content-type", "application/json;")
    |> send_resp(200, Jason.encode!(data, pretty: true))
  end

  def unauthorized(conn, nil) do
    conn
    |> send_resp(401, "unauthorized")
    |> halt()
  end


  def process_jwt(conn, _params) do
    jwt = List.first(Plug.Conn.get_req_header(conn, "authorization"))
    if is_nil(jwt) do
      unauthorized(conn, nil)
    else
      # IO.inspect(jwt, label: "jwt 76")
      # IO.inspect(String.split(jwt, "."))
      case Enum.count(String.split(jwt, ".")) == 3 do
        true -> # valid JWT proceed to verifying it
          # IO.inspect(jwt, label: "jwt 71")
          {:ok, claims} = App.Token.verify_and_validate(jwt)
          # IO.inspect(claims, label: "claims 73")
          sent = App.Ctx.upsert_sent(claims)
          # IO.inspect(sent, label: "sent 75")
          data = %{"id" => sent.id}
          conn
          |> put_resp_header("content-type", "application/json;")
          |> send_resp(200, Jason.encode!(data, pretty: true))

        false -> # invalid JWT return 401
          # IO.inspect("invalid jwt line 82")
          unauthorized(conn, nil)
      end
    end
  end

end
