//
//  migration.swift
//  
//
//  Created by Leanid Raichonak on 12.11.22.
//
import Fluent

struct CreateUsers: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("name", .string)
            .field("password_hash", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}

struct CreateTokens: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Token.schema)
            .id()
            .field("name", .string)
            .field("expiration_date", .date)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(Token.schema).delete()
    }
}
