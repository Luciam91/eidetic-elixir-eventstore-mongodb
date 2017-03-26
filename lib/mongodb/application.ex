defmodule Eidetic.EventStore.MongoDB.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Mongo, [[name: :mongo, hostname: "mongo", database: "event-store", pool: DBConnection.Poolboy]])
    ]

    opts = [strategy: :one_for_one, name: MongoDB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
