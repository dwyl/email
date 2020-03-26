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

  def create(conn, params) do
    attrs = Map.merge(Map.get(params, "sent"), %{"status" => "Pending"})
    send_email(attrs)

    conn
      # |> put_flash(:info, "💌 Email sent to: " <> Map.get(attrs, "email"))
      |> redirect(to: "/")
  end

  def send_email(attrs) do
    sent = Ctx.upsert_sent(attrs)
    payload = Map.merge(attrs, %{"id" => sent.id})
    # see: https://github.com/dwyl/elixir-invoke-lambda-example
    ExAws.Lambda.invoke("aws-ses-lambda-v1", payload, "no_context")
    |> ExAws.request(region: System.get_env("AWS_REGION"))

    sent
  end


  defp check_jwt_auth_header(conn) do
    jwt = List.first(Plug.Conn.get_req_header(conn, "authorization"))
    if is_nil(jwt) do
      {:error, nil}

    else # fast check for JWT format validity before slower verify:
      case Enum.count(String.split(jwt, ".")) == 3 do
        false ->
          {:error, nil}

        true -> # valid JWT proceed to verifying it
          App.Token.verify_and_validate(jwt)
      end
    end
  end

  defp check_jwt_url_params(%{"jwt" => jwt}) do
    if is_nil(jwt) do
      {:error, nil}
    else # fast check for JWT format validity before slower verify:
      case Enum.count(String.split(jwt, ".")) == 3 do
        false -> # invalid JWT return 401
          {:error, :invalid}
        true -> # valid JWT proceed to verifying it
          App.Token.verify_and_validate(jwt)
      end
    end
  end

  @doc """
  `unauthorized/2` reusable unauthorized response handler used in process_jwt/2
  """
  def unauthorized(conn, _params) do
    conn
    |> send_resp(401, "unauthorized")
    |> halt()
  end

  @doc """
  `process_sns/2` processes an API request with a JWT in authorization header.
  """
  def process_sns(conn, _params) do
    case check_jwt_auth_header(conn) do
      {:error, _} ->
        unauthorized(conn, _params)
      {:ok, claims} ->
        # IO.inspect(claims)
        sent = App.Ctx.upsert_sent(claims)
        data = %{"id" => sent.id}
        conn
        |> put_resp_header("content-type", "application/json;")
        |> send_resp(200, Jason.encode!(data, pretty: true))
    end
  end

  # This is the Base64 encoding for a 1x1 transparent pixel GIF for issue#1
  # stackoverflow.com/questions/4665960/most-efficient-way-to-display-a-1x1-gif
  @image "\x47\x49\x46\x38\x39\x61\x1\x0\x1\x0\x80\x0\x0\xff\xff\xff\x0\x0\x0\x21\xf9\x4\x1\x0\x0\x0\x0\x2c\x0\x0\x0\x0\x1\x0\x1\x0\x0\x2\x2\x44\x1\x0\x3b"

  @doc """
  `render_pixel/2` extracts the id of a sent item from a JWT in the URL
  and if the JWT is valid, updates the status to "Opened" and returns the pixel.
  """
  def render_pixel(conn, params) do
    case check_jwt_url_params(params) do
      {:error, _} ->
        unauthorized(conn, nil)

      {:ok, claims} ->
        App.Ctx.email_opened(Map.get(claims, "id"))

        conn # instruct browser not to cache the image
        |> put_resp_header("cache-control", "no-store, private")
        |> put_resp_header("pragma", "no-cache")
        |> put_resp_content_type("image/gif")
        |> send_resp(200, @image)
    end
  end


  # GET /ping https://github.com/dwyl/email/issues/30
  def ping(conn, _params) do
    conn
    |> put_resp_header("content-type", "application/json;")
    |> send_resp(200, Jason.encode!(Quotes.random(), pretty: true))
  end
end
