//
//  Errors.swift
//  PresenceKit
//
//  Created by Junaadh on 10/06/2025.
//

import Foundation

enum PresenceError: Error, LocalizedError {
    // MARK: - Decoding Errors

    case decodeOpcode
    case decodeHeader
    case insufficientData

    // MARK: - Response Errors

    case recieveUtf8Response
    case jsonParseResponse

    // MARK: - Encoding Errors
    
    case encodeJson

    // MARK: - IPC Connection Errors

    case ipcConnectionFailed
    case notConnected
    case sockCreateFailed(Error)
    case handShakeFailed(Error)

    // MARK: - IO Erros

    case readError(Error)
    case writeError(Error)
    case flushError(Error)

    // MARK: - Localized Error Conformance

    var errorDescription: String? {
        switch self {
        case .decodeOpcode:
            return "Failed to decode opcode"
        case .decodeHeader:
            return "Failed to decode header"
        case .insufficientData:
            return "Insufficient data to decode opcode and header"
        case .recieveUtf8Response:
            return "Failed to decode utf8 response. Invalid utf8"
        case .jsonParseResponse:
            return "Failed to parse json response. Invalid json format"
        case .encodeJson:
            return "Failed to encode json"
        case .ipcConnectionFailed:
            return "Connection to IPC socket failed"
        case .notConnected:
            return "Not Connected to an IPC socket"
        case let .sockCreateFailed(error):
            return "Failed to create raw socket: \(error)"
        case let .handShakeFailed(error):
            return "Failed to establish a handshake due to: \(error)"
        case let .readError(error):
            return "Read Error: \(error)"
        case let .writeError(error):
            return "Write Error: \(error)"
        case let .flushError(error):
            return "Flush Error: \(error)"
        }
    }
}
