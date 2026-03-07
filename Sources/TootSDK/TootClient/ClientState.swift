import Foundation
import Version

internal actor ClientState {
    var accessToken: String?
    var serverConfiguration: ServerConfiguration
    var currentApplicationInfo: TootApplication?

    init(accessToken: String?, serverConfiguration: ServerConfiguration = ServerConfiguration()) {
        self.accessToken = accessToken
        self.serverConfiguration = serverConfiguration
    }

    var flavour: TootSDKFlavour { serverConfiguration.flavour }
    var version: Version? { serverConfiguration.version }
    var versionString: String? { serverConfiguration.versionString }
    var apiVersions: InstanceV2.APIVersions? { serverConfiguration.apiVersions }

    var isAnonymous: Bool { accessToken == nil }

    func requestContext() -> (accessToken: String?, flavour: TootSDKFlavour) {
        (accessToken, serverConfiguration.flavour)
    }

    func featureContext() -> (TootSDKFlavour, Version?, InstanceV2.APIVersions?) {
        (serverConfiguration.flavour, serverConfiguration.version, serverConfiguration.apiVersions)
    }

    func setAccessToken(_ token: String?) {
        accessToken = token
    }

    func setServerConfiguration(_ config: ServerConfiguration) {
        serverConfiguration = config
    }

    func setCurrentApplicationInfo(_ app: TootApplication?) {
        currentApplicationInfo = app
    }

    func makeEncoder() -> TootEncoder {
        let encoder = TootEncoder()
        encoder.userInfo[.tootSDKFlavour] = serverConfiguration.flavour
        return encoder
    }
}
