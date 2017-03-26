defmodule Eidetic.EventStore.MongoDB do
  require Eidetic.Event
  @moduledoc """
  Documentation for MongoDB.
  """

  @doc """
  Inserts an event into the event-store
  """
  def insert(event = %Eidetic.Event{}) do
    {:ok, _} = Mongo.insert_one(:mongo, "events", %{event | datetime: DateTime.to_unix(event.datetime)}, pool: DBConnection.Poolboy)
  end

  @doc """
  Fetch event stream from the event-store
  """
  def fetch(identifier) do
    Mongo.find(:mongo, "events", %{"$query": %{identifier: identifier}}, pool: DBConnection.Poolboy)
    |> Enum.to_list
  end
end
