import Fluent

struct CreateUserSession: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_sessions")
            .id()
            .field("serverUrl", .string, .required)
            .field("clientId", .string)
            .field("clientSecret", .string)
            .field("accessToken", .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_sessions").delete()
    }
}
