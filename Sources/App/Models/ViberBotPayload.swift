//
//  ViberBotPayload.swift
//  
//
//  Created by Leanid Raichonak on 12.11.22.
//

import JWT

// JWT payload structure.
class ViberBotPayload: JWTPayload {
    init(subject: SubjectClaim, expiration: ExpirationClaim) {
        self.subject = subject
        self.expiration = expiration
    }
    
    // Maps the longer Swift property names to the
    // shortened keys used in the JWT payload.
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
    }

    // The "sub" (subject) claim identifies the principal that is the
    // subject of the JWT.
    var subject: SubjectClaim

    // The "exp" (expiration time) claim identifies the expiration time on
    // or after which the JWT MUST NOT be accepted for processing.
    var expiration: ExpirationClaim

    // Run any additional verification logic beyond
    // signature verification here.
    // Since we have an ExpirationClaim, we will
    // call its verify method.
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
