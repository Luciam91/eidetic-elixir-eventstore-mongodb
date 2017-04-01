defmodule Eidetic.EventStore.MongoDB.Application do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Mongo, [[name: :mongo,
                      hostname: Application.get_env(:eidetic_eventstore_mongodb, :hostname),
                      database: Application.get_env(:eidetic_eventstore_mongodb, :database),
                      pool: DBConnection.Poolboy]])
    ]

    opts = [strategy: :one_for_one, name: MongoDB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
