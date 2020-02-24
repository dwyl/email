defmodule App.Ctx.Sent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sent" do
    field :message_id, :string
    field :request_id, :string
    field :template, :string
    field :person_id, :id
    field :status_id, :id

    timestamps()
  end

  @doc false
  def changeset(sent, attrs) do
    sent
    |> cast(attrs, [:message_id, :request_id, :template])
    |> validate_required([:message_id, :request_id, :template])
  end
end
