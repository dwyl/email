defmodule App.Repo.Migrations.CreateSent do
  use Ecto.Migration

  def change do
    create table(:sent) do
      add :message_id, :string
      add :request_id, :string
      add :template, :string
      add :person_id, references(:people, on_delete: :nothing)
      add :status_id, references(:status, on_delete: :nothing)

      timestamps()
    end

    create index(:sent, [:person_id])
    create index(:sent, [:status_id])
  end
end
