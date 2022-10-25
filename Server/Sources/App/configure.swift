import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

var chatSystemShared: ChatSystem!

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateTodo())

    app.views.use(.leaf)


  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  let gameSystem = ChatSystem(eventLoop: app.eventLoopGroup.next())
  chatSystemShared = gameSystem

  app.webSocket("channel") { req, ws in
      gameSystem.connect(ws)
  }

  app.get { req in
      req.view.render("index.html")
  }

    // register routes
    try routes(app)
}
