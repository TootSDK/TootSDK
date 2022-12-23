import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { req async throws -> Response in
    let context = IndexContext(hasSession: try await UserSession.query(on: req.db).count() > 0)
    return try await req.view.render("index", context).encodeResponse(for: req)
  }

  try app.register(collection: TootController())
}

struct IndexContext: Encodable {
  let hasSession: Bool
}
