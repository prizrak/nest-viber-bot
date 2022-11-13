//
//  File.swift
//  
//
//  Created by Leanid Raichonak on 12.11.22.
//

import Foundation
import Vapor
import JWT
import struct ViberBotSwiftSDK.TextMessageRequestModel
import struct ViberBotSwiftSDK.SenderInfo
import struct ViberBotSwiftSDK.SendMessageResponseModel
import enum ViberBotSwiftSDK.Endpoint
import struct ViberBotSwiftSDK.TextMessageInternalRequestModel
import struct ViberBotSwiftSDK.SetWebhookRequestModel
import struct ViberBotSwiftSDK.SetWebhookResponseModel

extension URLRequest {
    mutating func applyJSONAsBody<T: Codable>(_ model: T) throws {
        let modelData = try JSONEncoder().encode(model)
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        httpBody = modelData
    }
}

public enum ViberBotError: Error {
    case senderNotDefined
    case endpointUrlIsNotValid
}

public final class ViberBot {
    let apiKey: String
    
    public var defaultSender: SenderInfo?
    
    public init(apiKey: String,
                defaultSender: SenderInfo? = nil) {
        self.apiKey = apiKey
        self.defaultSender = defaultSender
    }
}

// send messages
extension ViberBot {
    @discardableResult public func sendTextMessage(to receiver: String,
                                                   as sender: SenderInfo? = nil,
                                                   model: TextMessageRequestModel) async throws -> SendMessageResponseModel? {
        guard let usedSender = sender ?? defaultSender else {
            throw ViberBotError.senderNotDefined
        }

        let internalModel = TextMessageInternalRequestModel(text: model.text,
                                                            receiver: receiver,
                                                            sender: usedSender,
                                                            trackingData: model.trackingData,
                                                            authToken: apiKey)
        guard let url = URL(string: Endpoint.sendMessage.urlPath) else {
            throw ViberBotError.endpointUrlIsNotValid
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        try request.applyJSONAsBody(internalModel)
        let data = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data.0, options: [])
        print(json)
        return nil
    }
    
    @discardableResult public func setWebhook(endpointUrl: String) async throws -> SetWebhookResponseModel? {
        let model = SetWebhookRequestModel(url: endpointUrl, authToken: apiKey,
                                           //eventTypes: [.message, .conversationStarted, .subscribed, .unsubscribed],
                                           sendName: false, sendPhoto: false)
        guard let url = URL(string: Endpoint.setWebhook(model: model).urlPath) else {
            throw ViberBotError.endpointUrlIsNotValid
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        try request.applyJSONAsBody(model)
        let data = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data.0, options: [])
        print(json)
        return nil
    }
}

final class ViberController: RouteCollection {
    
    let viberApi: ViberBot
    
    init(_ app: Application) {
        viberApi = ViberBot(apiKey: app.config.viberApiKey,
                            defaultSender: SenderInfo(name: "hass.io"))
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("viber") { auth in
            auth.get("domofon", use: domofon)
            auth.get("webhook", use: webhook)
            auth.post("inbox", use: inbox)
        }
    }
    
    private func webhook(_ req: Request) async throws -> HTTPStatus {
        try req.jwt.verify(as: ViberBotPayload.self)
        try await viberApi.setWebhook(endpointUrl: req.application.config.apiURL)
        return .ok
    }
    
    private func inbox(_ req: Request) async throws -> HTTPStatus {
        return .ok
    }
    
    private func domofon(_ req: Request) async throws -> HTTPStatus {
        try req.jwt.verify(as: ViberBotPayload.self)
        let payload = try req.content.decode(Domofon.self)
        try await viberApi.sendTextMessage(to: "em:AQBBezPRvMl2ixpvAADVDcTmVkLbxekt/63MO9iDTVLr6FWAP+sycr5q",
                                           model: TextMessageRequestModel(text: "233"))
        return .ok
    }
}
