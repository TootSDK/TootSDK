import Fluent
import Vapor

final class UserSession: Model, Content {
    static let schema = "user_sessions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "serverUrl")
    var serverUrl: String

    @Field(key: "clientId")
    var clientId: String?

    @Field(key: "clientSecret")
    var clientSecret: String?

    @Field(key: "accessToken")
    var accessToken: String?

    init() {}

    init(
        id: UUID? = nil, serverUrl: String, clientId: String?, clientSecret: String?,
        accessToken: String?
    ) {
        self.id = id
        self.serverUrl = serverUrl
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.accessToken = accessToken
    }
}
