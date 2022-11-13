//
//  File.swift
//  
//
//  Created by Leanid Raichonak on 12.11.22.
//

import Fluent

final class Token: Model {
    init() {}
    
    static var schema = "tokens"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "expiration_date")
    var expirationDate: Date

    init(id: UUID? = nil, name: String, expirationDate: Date) {
        self.id = id
        self.name = name
        self.expirationDate = expirationDate
    }
}
