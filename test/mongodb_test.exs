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
          serial_number: 1,
          datetime: DateTime.utc_now(),
          payload: %{
            stuff: "Hello"
          }
        },
        %Eidetic.Event{
          type: "AnotherEventHappened",
          version: 1,
          identifier: aggregate_one_identifier,
          serial_number: 2,
          datetime: DateTime.utc_now(),
          payload: %{
            another: "Hello"
          }
        }
        ],
     aggregate_two_events: [
        %Eidetic.Event{
          type: "SomethingHappened",
          version: 1,
          identifier: aggregate_two_identifier,
          serial_number: 1,
          datetime: DateTime.utc_now(),
          payload: %{
            third: "Hello"
          }
        }
      ]
    ]
  end

  test "It can insert an event into the event-store", context do
    for event <- context[:aggregate_one_events] ++ context[:aggregate_two_events] do
      assert {:ok, [object_identifier: _object_identifier]} = GenServer.call(:eidetic_eventstore_adapter, {:record, event})
    end
  end

  test "It can fetch an event stream from the event store", context do
    {:ok, events} = GenServer.call(:eidetic_eventstore_adapter, {:fetch, context[:aggregate_one_identifier]})

    # Test Aggregate One is intact and ordered correctly
    assert context[:aggregate_one_events] == events
  end

  test "It can fetch a limited set of events from the event store", context do
    {:ok, events} = GenServer.call(:eidetic_eventstore_adapter, {:fetch_until, context[:aggregate_one_identifier], 1})

    assert [List.first(context[:aggregate_one_events])] == events
  end
end
