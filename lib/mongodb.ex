defmodule Eidetic.EventStore.MongoDB do
  @moduledoc """
  Documentation for MongoDB.
  """

  @doc """
  Inserts an event into the event-store
  """
  def record(event = %Eidetic.Event{}) do
    event
    |> transform_in
    |> insert
  end

  @doc """
  Fetch event stream from the event-store
  """
  def fetch(identifier) do
    identifier
    |> select
    |> transform_out
  end

  @doc false
  defp insert(document) do
    Mongo.insert_one(:mongo, "events", document, pool: DBConnection.Poolboy)
  end

  @doc false
  defp select(identifier) do
    Mongo.find(:mongo, "events", %{"$query": %{identifier: identifier}}, pool: DBConnection.Poolboy)
    |> Enum.to_list()
  end

  @doc false
  defp transform_in(event = %Eidetic.Event{}) do
    %{event | datetime: DateTime.to_iso8601(event.datetime)}
  end

  @doc false
  defp transform_out(events) when is_list(events) do
    Enum.reduce(events, [], fn(event, list) ->
      list ++ [transform_to_eidetic_event(event)]
    end)
  end

  @doc false
  defp transform_to_eidetic_event(event) when is_map(event) do
    {:ok, datetime, seconds} = DateTime.from_iso8601(event["datetime"])

    %Eidetic.Event{}
    |> Map.merge(Map.new(event, fn {k, v} -> {String.to_atom(k), v} end))
    |> Map.delete(:_id)
    |> Map.put(:datetime, datetime)
  end
end
