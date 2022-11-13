//
//  AuthenticationController.swift
//  
//
//  Created by Leanid Raichonak on 12.11.22.
//

import Vapor
import Fluent
import JWT

fileprivate enum Constants {
    static let TokenLifeTime = TimeInterval(3600)
}

struct AuthenticationController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("auth") { auth in
            auth.post("create_user", use: createUser)
            auth.grouped(User.authenticator())
                .grouped(User.guardMiddleware())
                .post("token", use: token)
        }
    }
    
    private func token(_ req: Request) async throws -> [String: String] {
        let user = try req.auth.require(User.self)
        
        let token = try await Token.query(on: req.db).filter(\.$name == user.name).first() ??
                                Token(name: user.name, expirationDate: Date(timeIntervalSinceNow: Constants.TokenLifeTime))
        if token.expirationDate.timeIntervalSinceNow < 5 {
            token.expirationDate = Date(timeIntervalSinceNow: Constants.TokenLifeTime)
            try await token.save(on: req.db)
        }
        
        let payload = ViberBotPayload(
            subject: SubjectClaim(value: user.name),
            //expiration: .init(value: token.expirationDate)
            expiration: .init(value: .distantFuture)
        )
        return try [
            "token": req.jwt.sign(payload)
        ]
    }
    
    private func createUser(_ req: Request) async throws -> User {
        if ["127.0.0.1"].firstIndex(of: req.peerAddress?.ipAddress) == nil {
            throw Abort(.forbidden, reason: "Can be performed from local network only")
        }
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            name: create.name,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return user
    }
}
