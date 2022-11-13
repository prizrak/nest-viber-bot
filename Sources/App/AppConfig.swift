//
//  AppConfig.swift
//  
//
//  Created by Leanid Raichonak on 12.11.22.
//

import Vapor

struct AppConfig {
    let apiURL: String
    let viberApiKey: String
    
    static var environment: AppConfig {
        guard
            let apiURL = Environment.get("API_URL"),
            let viberApiKey = Environment.get("VIBER_API_KEY")
            else {
                fatalError("Please add app configuration to environment variables")
        }
        
        return .init(apiURL: apiURL, viberApiKey: viberApiKey)
    }
}

extension Application {
    struct AppConfigKey: StorageKey {
        typealias Value = AppConfig
    }
    
    var config: AppConfig {
        get {
            storage[AppConfigKey.self] ?? .environment
        }
        set {
            storage[AppConfigKey.self] = newValue
        }
    }
}
