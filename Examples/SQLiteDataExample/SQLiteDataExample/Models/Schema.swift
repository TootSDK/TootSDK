//
//  Schema.swift
//  TootSDKExample
//
//  Created by Tim De Jong on 22/08/2025.
//
import Foundation
import OSLog
import SQLiteData

private let logger = Logger(subsystem: "SharingGRDBExample", category: "Database")

@Table
struct DisplayPost: Identifiable {

    let id: String
    let authorName: String
    let authorUsername: String
    let content: String
    let createdAt: Date
    let url: String
}

@Table
struct ServerCredential {
    let host: String
    let accessToken: String
}

func appDatabase() throws -> any DatabaseWriter {
    let database: any DatabaseWriter

    @Dependency(\.context) var context

    var configuration = Configuration()
    configuration.prepareDatabase { db in
        #if DEBUG
            db.trace(options: .profile) {
                if context == .preview {
                    print($0.expandedDescription)
                } else {
                    logger.debug("\($0.expandedDescription)")
                }
            }
        #endif
    }

    switch context
    {
    case .live:
        let path = URL.documentsDirectory.appendingPathComponent("bubbles.sqlite").path()
        logger.info("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    case .preview, .test:
        database = try DatabaseQueue(configuration: configuration)
    }

    var migrator = DatabaseMigrator()
    migrator.registerMigration("Create tables") { db in
        try #sql(
            """
            CREATE TABLE "serverCredentials" (
                "host" TEXT NOT NULL,
                "accessToken" TEXT NOT NULL
            )
            """
        )
        .execute(db)

        let id: String
        let authorName: String
        let authorUsername: String
        let content: String
        let createdAt: Date
        let url: String

        try #sql(
            """
            CREATE TABLE "displayPosts" (
                "id" TEXT PRIMARY KEY,
                "authorName" TEXT NOT NULL,
                "authorUsername" TEXT NOT NULL,
                "content" TEXT NOT NULL,
                "createdAt" TEXT NOT NULL,
                "url" TEXT NOT NULL
            )
            """
        )
        .execute(db)
    }

    #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
    #endif

    try migrator.migrate(database)

    return database
}
