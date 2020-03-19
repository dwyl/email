defmodule AppWeb.GithubVersionController do
  use AppWeb, :controller

  @doc """
  `index/2` returns the current git revision hash.
  This allows us to know exactly which version of the App is running.
  Note: it does not work on Heroku 😞 but it will work on other IaaS.
  """
  def index(conn, _params) do
    # leaving IO.inspect / puts in for debugging till further notice
    # IO.inspect(System.cmd("pwd", []))
    {ls, _} = System.cmd("ls", ["-a"])
    # IO.inspect ls
    ls = String.split(ls, "\n")
    # IO.inspect ls

    unless Enum.member?(ls, ".git") do
      File.cd("./builds")
      # IO.inspect(System.cmd("pwd", []))
    end

    {rev, _} = System.cmd("git", ["rev-parse", "HEAD"])
    # IO.puts(String.replace(rev, "\n", ""))
    text conn, String.replace(rev,  "\n", "")
  end
end
