//
//  GitHubEndpoint.swift
//  Modules
//
//  Created by Jacklandrin on 2022/5/26.
//

import Foundation

public let httpsScheme = "https"

public struct URLHost: RawRepresentable, Sendable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension URLHost {
    static var gitHubAPI: Self {
        URLHost(rawValue: "api.github.com")
    }

    static var userContent: Self {
        URLHost(rawValue: "raw.githubusercontent.com")
    }
}

public enum EndPointKinds: String, Sendable {
    case latestRelease = "repos/jacklandrin/OnlySwitch/releases/latest"
    case releases = "repos/jacklandrin/OnlySwitch/releases"
    case shortcutsJson = "jacklandrin/OnlySwitch/main/OnlySwitch/Resource/ShortcutsMarket/ShortcutsMarket.json"
}
