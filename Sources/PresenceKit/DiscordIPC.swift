//
//  DiscordIPC.swift
//  PresenceKit
//
//  Created by Junaadh on 10/06/2025.
//

import Foundation

public protocol DiscordIPC {
    func connect() throws
    func reconnect() throws
    func getClientId() -> String
    func connectIpc() throws
    func sendHandshake() throws
    func send(_ data: Data, _ op: UInt8) throws
    func write(_ data: [UInt8]) throws
    func recv() throws -> (UInt32, Data)
    func read(_ data: inout [UInt8]) throws
    func setActivity(_ payload: Activity) throws
    func clearActivity() throws
    func close() throws
}

extension DiscordIPC {
    public func connect() throws {
        try connectIpc()
        try sendHandshake()
    }

    public func reconnect() throws {
        try close()
        try connectIpc()
        try sendHandshake()
    }

    public func sendHandshake() throws {
        let payload: [String: Any] = [
            "v": 1,
            "client_id": getClientId(),
        ]

        let json_data = try JSONSerialization.data(withJSONObject: payload, options: [])
        try send(json_data, 0)

        let x = try recv()
        if x.0 == 2 {
            let err = try JSONDecoder().decode(HandShakeResponse.self, from: x.1)
            throw PresenceError.handShakeFailed(
                NSError(
                    domain: "handshake", code: Int(x.0),
                    userInfo: [NSLocalizedDescriptionKey: err.description]))
        } else {
            print(String(bytes: x.1, encoding: .utf8)!)
        }
    }

    public func send(_ data: Data, _ op: UInt8) throws {
        let header = UInt32(op).pack(len: UInt32(data.count))

        try write(header)
        try write([UInt8](data))
    }

    public func recv() throws -> (UInt32, Data) {
        var header = [UInt8](repeating: 0, count: 8)
        try read(&header)

        let (opcode, len) = try header.unpack().get()

        var payload = [UInt8](repeating: 0, count: Int(len))
        try read(&payload)

        return (UInt32(opcode), Data(payload))
    }

    public func setActivity(_ payload: Activity) throws {
        let encoder = JSONEncoder()

        let activity_data = try encoder.encode(payload)
        guard
            let activity_dict = try JSONSerialization.jsonObject(with: activity_data)
                as? [String: Any]
        else {
            throw PresenceError.encodeJson
        }

        let data: [String: Any] = [
            "cmd": "SET_ACTIVITY",
            "args": [
                "pid": ProcessInfo.processInfo.processIdentifier,
                "activity": activity_dict,
            ],
            "nonce": UUID().uuidString,
        ]

        print(data)

        let json_data = try JSONSerialization.data(withJSONObject: data, options: [])
        try send(json_data, 1)
    }

    public func clearActivity() throws {
        let data: [String: Any?] = [
            "cmd": "SET_ACTIVITY",
            "args": [
                "pid": ProcessInfo.processInfo.processIdentifier,
                "activity": nil,
            ],
            "nonce": UUID().uuidString,
        ]

        let json_data = try JSONSerialization.data(withJSONObject: data, options: [])
        try send(json_data, 1)
    }
}

struct HandShakeResponse: Decodable, CustomStringConvertible {
    let code: Code
    let message: String

    enum Code: UInt32, Decodable {
        case CloseNormal = 1000
        case CloseUnsupported = 1003
        case CloseAbnormal = 1006
        case InvalidClientId = 4000
        case InvalidOrigin = 4001
        case RateLimited = 4002
        case TokenRevoked = 4003
        case InvalidVersion = 4004
        case InvalidEncoding = 4005
    }

    var description: String {
        "DiscordClient responded with code:\(self.code) message: \(self.message)"
    }
}
