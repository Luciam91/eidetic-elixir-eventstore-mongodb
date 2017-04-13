Mongo.start_link([name: :mongo, hostname: "mongo", database: "events", pool: DBConnection.Poolboy])
Eidetic.EventStore.MongoDB.start_link([name: :eidetic_eventstore_adapter])

ExUnit.start()
