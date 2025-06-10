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
        var selfLe = withUnsafeBytes(of: self.littleEndian) { Array($0) }
        let lenLe = withUnsafeBytes(of: self.littleEndian) { Array($0) }
        selfLe.append(contentsOf: lenLe)
        
        return selfLe
    }
}

extension [UInt8]: Unpackable {
    func unpack() -> Result<(UInt32, UInt32), PresenceError> {
        guard self.count >= 8 || !self.isEmpty else {
            return .failure(.insufficientData)
        }
        
        let opcode_bytes = self[0..<4]
        let header_bytes = self[4..<8]
        
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
