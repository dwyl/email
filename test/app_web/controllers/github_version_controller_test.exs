defmodule AppWeb.GithubVersionControllerTest do
  use AppWeb.ConnCase

  test "GET /_version", %{conn: conn} do
    {rev, _} = System.cmd("git", ["rev-parse", "HEAD"])
    version = String.replace(rev, "\n", "")
    IO.puts version
    conn = get conn, "/_version"
    assert text_response(conn, 200) =~ version
  end
end
