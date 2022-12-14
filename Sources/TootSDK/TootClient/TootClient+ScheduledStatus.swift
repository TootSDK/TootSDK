//  TootClient+ScheduledStatus.swift
//  Created by dave on 7/12/22.

import Foundation

public extension TootClient {
    
    /// Schedules a status based on the components provided
    /// - Parameters:
    ///   - statusComponents: Status components to be published
    /// - Returns: the ScheduledStatus, if successful, throws an error if not
    func scheduleStatus(_ params: ScheduledStatusParams) async throws -> ScheduledStatus? {
        let requestParams = try ScheduledStatusRequest(from: params)
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "statuses"])
            $0.method = .post
            $0.body = try .multipart(requestParams, boundary: UUID().uuidString)
        }
        
        return try await fetch(ScheduledStatus.self, req)
    }
    
    /// Gets scheduled statuses
    /// - Parameters:
    ///   - minId: Return results immediately newer than ID.
    ///   - maxId: Return results older than ID
    ///   - sinceId: Return results newer than ID
    ///   - limit: Maximum number of results to return. Defaults to 20. Max 40
    /// - Returns: array of scheduled statuses (empty if none), an error if any issue
    func getScheduledStatus(minId: String?, maxId: String?, sinceId: String?, limit: Int?) async throws -> [ScheduledStatus] {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses"])
            $0.method = .get
            
            if let minId {
                $0.addQueryParameter(name: "min_id", value: minId)
            }
            
            if let maxId {
                $0.addQueryParameter(name: "max_id", value: maxId)
            }
            
            if let sinceId {
                $0.addQueryParameter(name: "since_id", value: sinceId)
            }
            
            if let limit {
                $0.addQueryParameter(name: "limit", value: String(limit))
            }
        }
        
        let scheduledStatuses = try await fetch([ScheduledStatus].self, req)
        return scheduledStatuses ?? []
    }
    
    /// Gets a single Scheduled Status by id
    ///
    /// - Parameter id: the ID of the status to be retrieved
    /// - Returns: the scheduled status retrieved, if successful, throws an error if not
    func getScheduledStatus(id: String) async throws -> ScheduledStatus? {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .get
        }
        
        return try await fetch(ScheduledStatus.self, req)
    }
    
    /// Edit a given status to change its text, sensitivity, media attachments, or poll. Note that editing a poll’s options will reset the votes.
    /// - Parameter id: the ID of the status to be changed
    /// - Parameter params: the updated content of the status to be posted
    /// - Returns: the status after the update
    func updateScheduledStatusDate(id: String, _ params: ScheduledStatusParams) async throws -> ScheduledStatus? {
        let requestParams = try ScheduledStatusRequest(from: params)
        let req = try HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .put
            $0.body = try .multipart(requestParams, boundary: UUID().uuidString)
        }
        
        return try await fetch(ScheduledStatus.self, req)
    }
    
    /// Deletes a single scheduled status
    /// - Parameter id: the ID of the status to be deleted
    /// - Returns: the status deleted (for delete and redraft), if successful, throws an error if not
    func deleteScheduledStatus(id: String) async throws {
        let req = HttpRequestBuilder {
            $0.url = getURL(["api", "v1", "scheduled_statuses", id])
            $0.method = .delete
        }
        
        let _ = try await fetch(req: req)
    }
    
}
