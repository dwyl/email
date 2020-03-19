defmodule App.Ctx do
  @moduledoc """
  The Ctx context.
  """

  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Ctx.{Sent, Status, Person}

  @doc """
  Returns the list of sent.

  ## Examples

      iex> list_sent()
      [%Sent{}, ...]

  """
  def list_sent do
    Repo.all(Sent)
  end


  @doc """
  `list_sent_with_status/0` Returns the list of sent items with the status.text
  I hand-crafted this SQL query becuase the Ecto queryable wasn't working.
  Feel free to refactor it if you know how.
  """
  def list_sent_with_status do
    query = """
      SELECT s.id, s.message_id, s.inserted_at, s.template,
      st.text as status, s.person_id
      FROM sent s
      JOIN status as st on s.status_id = st.id
      ORDER by s.updated_at DESC
    """
    {:ok, result} = Repo.query(query)

    Enum.map(result.rows, fn([id, mid, iat, t, s, pid]) ->
      %{
        id: id,
        message_id: mid,
        inserted_at: iat,
        template: t,
        status: s,
        person_id: pid
      }
    end)
  end


  @doc """
  Gets a single sent.

  Raises `Ecto.NoResultsError` if the Sent does not exist.

  ## Examples

      iex> get_sent!(123)
      %Sent{}

      iex> get_sent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sent!(id), do: Repo.get!(Sent, id)

  @doc """
  Creates a sent.

  ## Examples

      iex> create_sent(%{field: value})
      {:ok, %Sent{}}

      iex> create_sent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sent(attrs \\ %{}) do
    %Sent{}
    |> Sent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sent.

  ## Examples

      iex> update_sent(sent, %{field: new_value})
      {:ok, %Sent{}}

      iex> update_sent(sent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sent(%Sent{} = sent, attrs) do
    # IO.inspect(sent, label: "sent 70")
    sent
    |> Sent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sent.

  ## Examples

      iex> delete_sent(sent)
      {:ok, %Sent{}}

      iex> delete_sent(sent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sent(%Sent{} = sent) do
    Repo.delete(sent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sent changes.

  ## Examples

      iex> change_sent(sent)
      %Ecto.Changeset{source: %Sent{}}

  """
  def change_sent(%Sent{} = sent) do
    Sent.changeset(sent, %{})
  end

  @doc """
  `upsert_sent/1` inserts or updates a sent record.
  """
  def upsert_sent(attrs) do
    # transform attrs into Map with Atoms as Keys:
    attrs = for {k, v} <- attrs, into: %{}, do: {String.to_atom(k), v}
    # IO.inspect(attrs, label: "attrs")
    # Step 1: Check if the Person exists by email address:
    person_id = case Map.has_key?(attrs, :email) do
      true ->
        case Person.get_person_by_email(attrs.email) do
          nil -> # create a new person record
            {:ok, person} = %Person{}
              |> Person.changeset(%{email: attrs.email})
              |> Repo.insert()
            # IO.inspect(person, label: "person")
            person.id

          person ->
            person.id
        end

      false ->
        nil
    end

    # Step 2: Check if the status exists
    status_id = case Repo.get_by(Status, text: attrs.status) do
      nil -> # create a new status record
        record = %{text: attrs.status, person_id: person_id}
        {:ok, status} = Status.create_status(record)
        status.id

      status ->
        status.id
    end

    # Step 3. Insert or Update (UPSERT) then return the sent record:
    case Repo.get_by(Sent, message_id: attrs.message_id) do
      nil -> # create a new sent record
        {:ok, sent} =
          %Sent{ status_id: status_id, person_id: person_id }
          |> Sent.changeset(attrs)
          |> Repo.insert()
          # |> IO.inspect(label: "sent")
        sent

      sent -> # update status of existing sent record
        {:ok, sent} = update_sent(sent, %{status_id: status_id})
        sent
    end
  end
end
