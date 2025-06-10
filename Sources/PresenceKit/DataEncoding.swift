//
//  DataEncoding.swift
//  PresenceKit
//
//  Created by Junaadh on 10/06/2025.
//

protocol Packacble {
    func pack(len: UInt32) -> [UInt8]
}

protocol Unpackable {
    func unpack() -> Result<(UInt32, UInt32), PresenceError>
}

extension UInt32: Packacble {
    func pack(len: UInt32) -> [UInt8] {
        var array = [UInt8](repeating: 0, count: 8)
        let selfBytes = withUnsafeBytes(of: littleEndian) { Array($0) }
        let lenBytes = withUnsafeBytes(of: len.littleEndian) { Array($0) }

        array[0 ..< 4] = selfBytes[0 ..< 4]
        array[4 ..< 8] = lenBytes[0 ..< 4]
        return array
    }
}

extension [UInt8]: Unpackable {
    func unpack() -> Result<(UInt32, UInt32), PresenceError> {
        guard count >= 8 || !isEmpty else {
            return .failure(.insufficientData)
        }

        let opcode_bytes = self[0 ..< 4]
        let header_bytes = self[4 ..< 8]

        let opcode: UInt32? = opcode_bytes.withUnsafeBytes {
            $0.load(as: UInt32.self)
        }.littleEndian

        guard let validOpcode = opcode else {
            return .failure(.decodeOpcode)
        }

        let header: UInt32? = header_bytes.withUnsafeBytes {
            $0.load(as: UInt32.self)
        }.littleEndian

        guard let validHeader = header else {
            return .failure(.decodeHeader)
        }

        return .success((validOpcode, validHeader))
    }
}
