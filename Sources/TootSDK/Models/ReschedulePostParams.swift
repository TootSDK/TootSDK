import Foundation

/// Parameters to update a scheduled post's publication date.
public struct ReschedulePostParams: Sendable {

    /// Date and time at which the post will be published.
    public let scheduledAt: Date

    /// Creates parameters to update a scheduled post's publication date.
    ///
    /// - Parameter scheduledAt: Date and time at which the post will be published. Must be at least five minutes in the future.
    public init(scheduledAt: Date) {
        self.scheduledAt = scheduledAt
    }
}

extension ReschedulePostParams {
    func queryItems() throws -> [URLQueryItem] {
        if scheduledAt < Date().addingTimeInterval(TimeInterval(5.0 * 60.0)) {
            throw TootSDKError.invalidParameter(
                parameterName: "scheduledAt",
                reason: "The scheduled date must be at least 5 minutes into the future."
            )
        }

        return [URLQueryItem(name: "scheduled_at", value: TootEncoder.dateFormatter.string(from: scheduledAt))]
    }
}
