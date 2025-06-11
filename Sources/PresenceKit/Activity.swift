//
//  Activity.swift
//  PresenceKit
//
//  Created by Junaadh on 10/06/2025.
//

import Foundation

public class Activity: Encodable {
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

    public init(
        state: String? = nil,
        details: String? = nil,
        timestamps: Timestamps? = nil,
        party: Party? = nil,
        assets: Assets? = nil,
        secrets: Secrets? = nil,
        buttons: [Button]? = nil,
        activityType: ActivityType? = nil
    ) {
        self.state = state
        self.details = details
        self.timestamps = timestamps
        self.party = party
        self.assets = assets
        self.secrets = secrets
        self.buttons = buttons
        self.activityType = activityType
    }

    public init(from payload: [String: Any]) {
        self.state = payload["state"] as? String
        self.details = payload["details"] as? String
        self.assets = (payload["assets"] as? [String: Any]).map { Assets(from: $0) }
        self.buttons = (payload["buttons"] as? [[String: Any]]).map { Button.from(array: $0) }
        self.activityType = ActivityType(from: payload["activity_type"])
    }

    public func toNSDictionary() -> NSDictionary? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let data = try encoder.encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? NSDictionary
        } catch let err {
            print(err)
            return nil
        }
    }

    @discardableResult public func setState(_ value: String) -> Self {
        state = value
        return self
    }

    @discardableResult public func setDetails(_ value: String) -> Self {
        details = value
        return self
    }

    @discardableResult public func setTimestamps(_ value: Timestamps) -> Self {
        timestamps = value
        return self
    }

    @discardableResult public func setParty(_ value: Party) -> Self {
        party = value
        return self
    }

    @discardableResult public func setAssets(_ value: Assets) -> Self {
        assets = value
        return self
    }

    @discardableResult public func setSecrets(_ value: Secrets) -> Self {
        secrets = value
        return self
    }

    @discardableResult public func setButtons(_ value: [Button]) -> Self {
        if !value.isEmpty {
            buttons = value
        }
        return self
    }

    @discardableResult public func setActivityType(_ value: ActivityType) -> Self {
        activityType = value
        return self
    }
}

public class Timestamps: Codable {
    var start: Int64? = nil
    var end: Int64? = nil

    public init() {}

    public init(start: Int64? = nil, end: Int64? = nil) {
        self.start = start
        self.end = end
    }

    @discardableResult public func setStart(_ value: Int64) -> Self {
        start = value
        return self
    }

    @discardableResult public func setEnd(_ value: Int64) -> Self {
        end = value
        return self
    }
}

public class Party: Codable {
    var id: String? = nil
    var size: [Int]? = nil

    public init() {}

    public init(id: String? = nil, size: [Int]? = nil) {
        self.id = id
        self.size = size
    }

    @discardableResult public func setId(_ value: String) -> Self {
        id = value
        return self
    }

    @discardableResult public func setSize(_ value: [Int]) -> Self {
        size = value
        return self
    }
}

public class Assets: Codable {
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

    public init(
        largeImage: String? = nil, largeText: String? = nil, smallImage: String? = nil,
        smallText: String? = nil
    ) {
        self.largeImage = largeImage
        self.largeText = largeText
        self.smallImage = smallImage
        self.smallText = smallText
    }

    public init(from payload: [String: Any]) {
        self.largeImage = payload["large_image"] as? String
        self.smallImage = payload["small_image"] as? String
        self.largeText = payload["large_text"] as? String
        self.smallText = payload["small_text"] as? String
    }

    @discardableResult public func setLargeImage(_ value: String) -> Self {
        largeImage = value
        return self
    }

    @discardableResult public func setLargeText(_ value: String) -> Self {
        largeText = value
        return self
    }

    @discardableResult public func setSmallImage(_ value: String) -> Self {
        smallImage = value
        return self
    }

    @discardableResult public func setSmallText(_ value: String) -> Self {
        smallText = value
        return self
    }
}

public class Secrets: Codable {
    var join: String? = nil
    var spectate: String? = nil
    var matchField: String? = nil

    enum CodingKeys: String, CodingKey {
        case join
        case spectate
        case matchField = "match"
    }

    public init() {}

    public init(join: String? = nil, spectate: String? = nil, matchField: String? = nil) {
        self.join = join
        self.spectate = spectate
        self.matchField = matchField
    }

    @discardableResult public func setJoin(_ value: String) -> Self {
        join = value
        return self
    }

    @discardableResult public func setSpectate(_ value: String) -> Self {
        spectate = value
        return self
    }

    @discardableResult public func setMatch(_ value: String) -> Self {
        matchField = value
        return self
    }
}

public final class Button: Codable {
    var label: String
    var url: String

    public init(label: String, url: String) {
        self.label = label
        self.url = url
    }

    public init?(from payload: [String: Any]) {
        guard
            let label = payload["label"] as? String,
            let url = payload["label"] as? String
        else { return nil }

        self.label = label
        self.url = url
    }

    public static func from(array payload: [[String: Any]]) -> [Button] {
        return payload.compactMap { Self.init(from: $0) }
    }
}

public enum ActivityType: UInt8, Codable {
    case playing = 0
    case streaming = 1
    case listening = 2
    case watching = 3
    case custom = 4
    case competing = 5
}

extension ActivityType {
    public init(from payload: Any?) {
        let raw = payload as? UInt8 ?? 0
        self = ActivityType(rawValue: raw) ?? ActivityType.playing
    }
}
