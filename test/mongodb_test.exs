defmodule Test.Eidetic.EventStore.MongoDB do
  use ExUnit.Case

  setup_all do
    [identifier: UUID.uuid4()]
  end

  test "It can insert an event into the event-store", context do
    assert {:ok, %Mongo.InsertOneResult{inserted_id: _}} = Eidetic.EventStore.MongoDB.insert(%Eidetic.Event{
      type: "EventHappened",
      version: 1,
      identifier: context[:identifier],
      serial_number: 1
    })
  end

  test "It can fetch an event stream from the event store", context do
    events = Eidetic.EventStore.MongoDB.fetch(context[:identifier])

    assert length(events) == 1
    assert context[:identifier] == List.first(events)["identifier"]
  end
end
