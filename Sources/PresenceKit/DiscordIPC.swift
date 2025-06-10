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
    func get_client_id() -> String
    func connect_ipc() throws
    func send_handshake() throws
    func send(_ data: Data, _ op: UInt8) throws
    func write(_ data: [UInt8]) throws
    func recv() throws -> (UInt32, Any)
    func read(_ data: inout [UInt8]) throws
    func set_activity(_ payload: Activity) throws
    func clear_activity() throws
    func close() throws
}

extension DiscordIPC {
    public func connect() throws {
        try connect_ipc()
        try send_handshake()
    }
    
    public func reconnect() throws {
        try self.close()
        try self.connect_ipc()
        try self.send_handshake()
    }
    
    public func send_handshake() throws {
        let payload: [String: Any] = [
            "v": 1,
            "client_id": self.get_client_id()
        ]
        
        let json_data = try JSONSerialization.data(withJSONObject: payload, options: [])
        try self.send(json_data, 0)
        
        _ = try self.recv()
    }
    
    public func send(_ data: Data, _ op: UInt8) throws {
        let header = UInt32(op).pack(len: UInt32(data.count))
        
        try self.write(header)
        try self.write([UInt8](data))
    }
    
    public func recv() throws -> (UInt32, Any) {
        var header = [UInt8](repeating: 0, count: 8)
        try self.read(&header)
        
        let (opcode, len) = try header.unpack().get()
        
        var payload = [UInt8](repeating: 0, count: Int(len))
        try self.read(&payload)
        
        guard let json_string = String(bytes: payload, encoding: .utf8) else {
            throw PresenceError.recieveUtf8Response
        }
        
        let json_object = try JSONSerialization.jsonObject(with: Data(json_string.utf8), options: [])
        
        return (UInt32(opcode), json_object)
    }
    
    public func set_activity(_ payload: Activity) throws {
        let encoder = JSONEncoder()
        
        let activity_data = try encoder.encode(payload)
        guard let activity_dict = try JSONSerialization.jsonObject(with: activity_data) as? [String: Any] else {
            throw PresenceError.encodeJson
        }
        
        let data: [String: Any] = [
            "cmd": "SET_ACTIVITY",
            "args": [
                "pid": ProcessInfo.processInfo.processIdentifier,
                "activity": activity_dict,
            ],
            "nonce": UUID().uuidString
        ]
        
        let json_data = try JSONSerialization.data(withJSONObject: data, options: [])
        try self.send(json_data, 1)
    }
    
    public func clear_activity() throws {
        let data: [String: Any?] = [
            "cmd": "SET_ACTIVITY",
            "args": [
                "pid": ProcessInfo.processInfo.processIdentifier,
                "activity": nil,
            ],
            "nonce": UUID().uuidString
        ]
        
        let json_data = try JSONSerialization.data(withJSONObject: data, options: [])
        try self.send(json_data, 1)
    }
}

