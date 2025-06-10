//
//  Activity.swift
//  PresenceKit
//
//  Created by Junaadh on 10/06/2025.
//

import Foundation

public struct Activity: Encodable {
    var state: String? = nil
    var details: String? = nil
    var timestamps: Timestamps? = nil
    var party: Party? = nil
    var assets: Assets? = nil
    var secrets: Secrets? = nil
    var buttons: [Button]? = nil
    var activityType: ActivityType? = nil

    enum CodingKeys: String, CodingKey {
        case state, details, timestamps, party, assets, secrets, buttons
        case activityType = "type"
    }
    
    public init() {}
    
    @discardableResult public mutating func setState(_ value: String) -> Self {
        state = value
        return self
    }

    @discardableResult public mutating func setDetails(_ value: String) -> Self {
        details = value
        return self
    }

    @discardableResult public mutating func setTimestamps(_ value: Timestamps) -> Self {
        timestamps = value
        return self
    }

    @discardableResult public mutating func setParty(_ value: Party) -> Self {
        party = value
        return self
    }

    @discardableResult public mutating func setAssets(_ value: Assets) -> Self {
        assets = value
        return self
    }

    @discardableResult public mutating func setSecrets(_ value: Secrets) -> Self {
        secrets = value
        return self
    }

    @discardableResult public mutating func setButtons(_ value: [Button]) -> Self {
        if !value.isEmpty {
            buttons = value
        }
        return self
    }

    @discardableResult public mutating func setActivityType(_ value: ActivityType) -> Self {
        activityType = value
        return self
    }
}

public struct Timestamps: Codable {
    var start: Int64? = nil
    var end: Int64? = nil
    
    public init() {}

    @discardableResult public mutating func setStart(_ value: Int64) -> Self {
        start = value
        return self
    }

    @discardableResult public mutating func setEnd(_ value: Int64) -> Self {
        end = value
        return self
    }
}

public struct Party: Codable {
    var id: String? = nil
    var size: [Int]? = nil
    
    public init() {}

    @discardableResult public mutating func setId(_ value: String) -> Self {
        id = value
        return self
    }

    @discardableResult public mutating func setSize(_ value: [Int]) -> Self {
        size = value
        return self
    }
}

public struct Assets: Codable {
    var largeImage: String? = nil
    var largeText: String? = nil
    var smallImage: String? = nil
    var smallText: String? = nil

    enum CodingKeys: String, CodingKey {
        case largeImage = "large_image"
        case largeText = "large_text"
        case smallImage = "small_image"
        case smallText = "small_text"
    }
    
    public init() {}

    @discardableResult public mutating func setLargeImage(_ value: String) -> Self {
        largeImage = value
        return self
    }

    @discardableResult public mutating func setLargeText(_ value: String) -> Self {
        largeText = value
        return self
    }

    @discardableResult public mutating func setSmallImage(_ value: String) -> Self {
        smallImage = value
        return self
    }

    @discardableResult public mutating func setSmallText(_ value: String) -> Self {
        smallText = value
        return self
    }
}

public struct Secrets: Codable {
    var join: String? = nil
    var spectate: String? = nil
    var matchField: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case join
        case spectate
        case matchField = "match"
    }
    
    public init() {}

    @discardableResult public mutating func setJoin(_ value: String) -> Self {
        join = value
        return self
    }

    @discardableResult public mutating func setSpectate(_ value: String) -> Self {
        spectate = value
        return self
    }

    @discardableResult public mutating func setMatch(_ value: String) -> Self {
        matchField = value
        return self
    }
}

public struct Button: Codable {
    var label: String
    var url: String
    
    public init(label: String, url: String) {
        self.label = label
        self.url = url
    }
}

public enum ActivityType: UInt8, Codable {
    case playing = 0
    case listening = 2
    case watching = 3
    case competing = 5
}
