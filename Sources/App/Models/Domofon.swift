//
//  File.swift
//  
//
//  Created by Leanid Raichonak on 12.11.22.
//

import Vapor

struct Domofon: Content {
    
    var state: State
    
    enum State: Int, Codable {
        case idle
        case calling
    }
}
