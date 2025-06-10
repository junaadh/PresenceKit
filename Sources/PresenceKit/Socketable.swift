//
//  Socketable.swift
//  PresenceKit
//
//  Created by Junaadh on 10/06/2025.
//

import Darwin
import Foundation

public protocol Socketable {
    func wrapSocket() throws -> FileHandle
}

extension URL: Socketable {
    public func wrapSocket() throws -> FileHandle {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else {
            throw PresenceError.sockCreateFailed(NSError(domain: "SocketError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create socket"]))
        }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)

        let socketPath = path
        let pathBytes = socketPath.utf8CString

        guard pathBytes.count <= MemoryLayout.size(ofValue: addr.sun_path) else {
            close(fd)
            throw PresenceError.sockCreateFailed(NSError(domain: "SocketError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Socket path too long"]))
        }

        pathBytes.withUnsafeBytes { srcPtr in
            withUnsafeMutableBytes(of: &addr.sun_path) { dstPtr in
                dstPtr.baseAddress!.copyMemory(from: srcPtr.baseAddress!, byteCount: pathBytes.count)
            }
        }

        let len = socklen_t(MemoryLayout.size(ofValue: addr.sun_family) + pathBytes.count)
        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(fd, $0, len)
            }
        }

        guard result == 0 else {
            close(fd)
            throw PresenceError.sockCreateFailed(NSError(domain: "SocketError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to connect to socket at \(path)"]))
        }

        return FileHandle(fileDescriptor: fd, closeOnDealloc: true)
    }
}
