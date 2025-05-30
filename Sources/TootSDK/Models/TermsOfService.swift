import Foundation

/// The terms of service of an instance.
public struct TermsOfService: Codable, Hashable, Sendable {

    /// The date these terms of service are coming or have come in effect.
    public var effectiveDate: Date

    /// Whether these terms of service are currently in effect.
    public var effective: Bool

    /// If there are newer terms of service, their effective date.
    ///
    /// You can get the newer version by passing this date as the parameter for ``TootClient/getTermsOfService(effectiveAsOf:)``.
    public var succeededBy: Date?

    /// The rendered HTML content of the terms of service.
    public var content: String

    public init(effectiveDate: Date, effective: Bool, succeededBy: Date? = nil, content: String = "") {
        self.effectiveDate = effectiveDate
        self.effective = effective
        self.succeededBy = succeededBy
        self.content = content
    }
}
