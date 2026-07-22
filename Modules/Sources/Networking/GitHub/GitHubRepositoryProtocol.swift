//
//  GithubRepositoryProtocol.swift
//  Modules
//
//  Created by Jacklandrin on 2022/7/4.
//

import Foundation

public protocol GitHubRepositoryProtocol {
    var latestVersion: String { get }
    var downloadURL: String { get }
    var isTheNewestVersion: Bool { get }
    var downloadCount: Int { get }
    var updateHistoryInfo: String { get }

    func checkUpdate<Release: GitHubReleaseLike>(releaseType: Release.Type, complete: @escaping (Result<Void, Error>) -> Void)
    func requestReleases<Release: GitHubReleaseLike>(releaseType: Release.Type, complete: @escaping (Result<Void, Error>) -> Void)
    func downloadDMG(complete: @escaping (Result<String, Error>) -> Void)
    func requestShortcutsJson<T: Decodable>(type: T.Type, complete: @escaping (Result<T, Error>) -> Void)
}
