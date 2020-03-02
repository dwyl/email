defmodule App.Ctx.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Repo

  schema "status" do
    field :text, :string
    belongs_to :person, App.Ctx.Person

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end

  @doc """
  Creates a status.

  ## Examples

      iex> create_status(%{text: "amazing"})
      {:ok, %Status{}}

      iex> create_status(%{text: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_status(attrs \\ %{}) do
    # IO.inspect(__MODULE__, label: "__MODULE__")
    # IO.inspect(attrs, label: "create_status attrs")
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
