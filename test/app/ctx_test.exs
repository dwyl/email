defmodule App.CtxTest do
  use App.DataCase

  alias App.Ctx

  describe "sent" do
    alias App.Ctx.Sent

    @valid_attrs %{message_id: "some message_id", request_id: "some request_id", template: "some template"}
    @update_attrs %{message_id: "some updated message_id", request_id: "some updated request_id", template: "some updated template"}
    # @invalid_attrs %{message_id: nil, request_id: nil, template: nil}

    def sent_fixture(attrs \\ %{}) do
      {:ok, sent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_sent()

      sent
    end

    # open a JSON fixture file and return an Elixir Map
    def get_json(filename) do
      # IO.inspect(filename, label: "filename")
      # IO.inspect(File.cwd!, label: "cwd")
      {:ok, body} = File.read(filename)
      {:ok, json} = Jason.decode(body)
      # IO.inspect json, label: "json"
      json
    end

    test "list_sent/0 returns all sent" do
      sent = sent_fixture()
      # IO.inspect(sent, label: "sent 34")
      # IO.inspect(Ctx.list_sent(), label: "list_sent() 35")
      assert Ctx.list_sent() == [sent]
    end

    test "get_sent!/1 returns the sent with given id" do
      sent = sent_fixture()
      assert Ctx.get_sent!(sent.id) == sent
    end

    test "create_sent/1 with valid data creates a sent" do
      assert {:ok, %Sent{} = sent} = Ctx.create_sent(@valid_attrs)
      assert sent.message_id == "some message_id"
      assert sent.request_id == "some request_id"
      assert sent.template == "some template"
    end

    # test "create_sent/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Ctx.create_sent(@invalid_attrs)
    # end

    test "update_sent/2 with valid data updates the sent" do
      sent = sent_fixture()
      assert {:ok, %Sent{} = sent} = Ctx.update_sent(sent, @update_attrs)
      assert sent.message_id == "some updated message_id"
      assert sent.request_id == "some updated request_id"
      assert sent.template == "some updated template"
    end

    # test "update_sent/2 with invalid data returns error changeset" do
    #   sent = sent_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Ctx.update_sent(sent, @invalid_attrs)
    #   assert sent == Ctx.get_sent!(sent.id)
    #   # IO.inspect sent, label: "sent 65"
    # end

    test "delete_sent/1 deletes the sent" do
      sent = sent_fixture()
      assert {:ok, %Sent{}} = Ctx.delete_sent(sent)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_sent!(sent.id) end
    end

    test "change_sent/1 returns a sent changeset" do
      sent = sent_fixture()
      assert %Ecto.Changeset{} = Ctx.change_sent(sent)
    end

    test "upsert_sent/1 inserts a valid NEW sent record with email" do

      data = %{
        "message_id" => "0102017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Sent",
        "email" => "amaze@gmail.com",
        "template" => "welcome"
      }
      sent = Ctx.upsert_sent(data)

      data2 = %{ # same message_id update the status
        "message_id" => "0102017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Bounce"
      }
      sent2 = Ctx.upsert_sent(data2)

      assert sent.person_id == sent2.person_id
      assert sent.status_id !== sent2.status_id
    end

    test "upsert_sent/1 update status for existing sent record" do
      init = %{
        "message_id" => "0102017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Sent",
        "email" => "amaze@gmail.com",
        "template" => "welcome"
      }
      sent = Ctx.upsert_sent(init)

      bounce = %{
        "message_id" => "0102017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Bounce Permanent"
      }
      sent2 = Ctx.upsert_sent(bounce)
      # IO.inspect(sent, label: "sent 113")
      # IO.inspect(sent2, label: "sent2 114")
      assert sent.id == sent2.id
      assert sent.status_id == sent2.status_id - 1

    end

    test "upsert_sent/1 insert new sent with same status" do

      bounce = %{
        "message_id" => "0102017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Bounce Permanent"
      }
      sent = Ctx.upsert_sent(bounce)

      bounce2 = %{
        "message_id" => "1232017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Bounce Permanent"
      }
      sent2 = Ctx.upsert_sent(bounce2)
      assert sent.id !== sent2.id
      assert sent.status_id == sent2.status_id
    end


    test "upsert_sent/1 insert two sent records for the same email" do

      init = %{
        "message_id" => "1232017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Sent",
        "email" => "amaze@gmail.com",
        "template" => "welcome"
      }
      sent = Ctx.upsert_sent(init)

      second = %{
        "message_id" => "4562017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Sent",
        "email" => "amaze@gmail.com",
      }
      sent2 = Ctx.upsert_sent(second)
      assert sent.person_id == sent2.person_id
      assert sent.status_id == sent2.status_id
    end

    test "upsert_sent/1 insert record with blank message_id then update it!" do

      init = %{
        "status" => "Sent",
        "email" => "amaze@gmail.com",
        "template" => "welcome"
      }
      sent = Ctx.upsert_sent(init)
      # IO.inspect(sent, label: "sent")
      assert sent.message_id == nil
      update = Map.merge(init, %{"status" => "Updated", "id" => sent.id})
      # IO.inspect(update, label: "update")
      sent2 = Ctx.upsert_sent(update)
      # IO.inspect(sent2, label: "sent2")
      # when the status is updated the status_id is the next status.id
      assert sent.status_id == sent2.status_id - 1
    end

    test "list_sent_with_status/0 returns list of maps" do
      item = %{
        "message_id" => "1232017092006798-f0456694-ac24-487b-9467-b79b8ce798f2",
        "status" => "Sent",
        "email" => "amaze@gmail.com",
        "template" => "welcome"
      }
      Ctx.upsert_sent(item)
      list = Ctx.list_sent_with_status()
      first = Enum.at(list, 0)
      assert first.status == "Sent"
    end

    test "email_opened/1 updates the status_id of a sent item to Opened" do

      {:ok, sent} = Ctx.create_sent(%{"message_id" => "123"})
      assert sent.status_id == nil

      updated = Ctx.email_opened(sent.id)

      {:ok, sent2} = Ctx.create_sent(%{"message_id" => "1234"})
      updated2 = Ctx.email_opened(sent2.id)

      assert updated.status_id == updated2.status_id
    end
  end
end
