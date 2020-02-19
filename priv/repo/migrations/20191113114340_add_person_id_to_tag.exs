defmodule App.Repo.Migrations.AddPersonIdToTag do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :person_id, references(:people, on_delete: :nothing)
    end
  end
end
