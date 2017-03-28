defmodule Test.Eidetic.EventStore.MongoDB do
  use ExUnit.Case, async: false

  setup_all do

    aggregate_one_identifier = UUID.uuid4()
    aggregate_two_identifier = UUID.uuid4()

    [aggregate_one_identifier: aggregate_one_identifier,
     aggregate_two_identifier: aggregate_two_identifier,
     aggregate_one_events: [
        %Eidetic.Event{
          type: "EventHappened",
          version: 1,
          identifier: aggregate_one_identifier,
          serial_number: 1},
        %Eidetic.Event{
          type: "AnotherEventHappened",
          version: 1,
          identifier: aggregate_one_identifier,
          serial_number: 2}
        ],
     aggregate_two_events: [
        %Eidetic.Event{
          type: "SomethingHappened",
          version: 1,
          identifier: aggregate_two_identifier,
          serial_number: 1
        }
      ]
    ]
  end

  test "It can insert an event into the event-store", context do
    for event <- context[:aggregate_one_events] do
      assert {:ok, %Mongo.InsertOneResult{inserted_id: _}} = Eidetic.EventStore.MongoDB.record(event)
    end

    for event <- context[:aggregate_two_events] do
      assert {:ok, %Mongo.InsertOneResult{inserted_id: _}} = Eidetic.EventStore.MongoDB.record(event)
    end
  end

  test "It can fetch an event stream from the event store", context do
    events = Eidetic.EventStore.MongoDB.fetch(context[:aggregate_one_identifier])

    # Test Aggregate One is intact and ordered correctly
    assert context[:aggregate_one_events] == events
  end
end
