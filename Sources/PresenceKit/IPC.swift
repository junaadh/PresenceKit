//
//  IPC.swift
//  PresenceKit
//
//  Created by Junaadh on 10/06/2025.
//

import Foundation

public final class DiscordIPCClient: DiscordIPC {
    public func get_client_id() -> String {
        self.client_id
    }
    
    public func connect_ipc() throws {
        let basePath = Self.getPipeBasePath()
        
        for i in 0..<10 {
            let ipcPath = basePath.appendingPathComponent("discord-ipc-\(i)")
            if FileManager.default.fileExists(atPath: ipcPath.path) {
                do {
                    let handle = try FileHandle(forUpdating: ipcPath)
                    self.sock = handle
                    return
                } catch {
                    continue // Try the next pipe index
                }
            }
        }
        
        throw PresenceError.ipcConnectionFailed
    }
    
    public func write(_ data: [UInt8]) throws {
        guard let socket = self.sock else {
            throw PresenceError.notConnected
        }
        do {
            try socket.write(contentsOf: data)
        } catch let er {
            throw PresenceError.writeError(er)
        }
    }
    
    public func read(_ data: inout [UInt8]) throws {
        guard let socket = self.sock else {
            throw PresenceError.notConnected
        }
        
        let expected_len = data.count
        do {
            guard let res = try socket.read(upToCount: expected_len) else {
                throw PresenceError.readError(NSError(domain: "PresenseIPC", code: -1, userInfo: [NSLocalizedDescriptionKey: "Socket closed or no data read"]))
            }
            data = [UInt8](res)
        } catch let err {
            throw PresenceError.readError(err)
        }
    }
    
    public func close() throws {
        guard let socket = self.sock else {
            throw PresenceError.notConnected
        }
        
        do {
            let payload = try JSONSerialization.data(withJSONObject: [:])
            try self.send(payload, 2)
        } catch {}
        
        do {
            try socket.close()
        } catch let err {
            throw PresenceError.flushError(err)
        }
    }
    
    public let client_id: String
    private var sock: FileHandle?
    
    public init(client_id: String) {
        self.client_id = client_id
    }
    
    private static func getPipeBasePath() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
}
