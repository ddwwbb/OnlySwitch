//
//  GitHubRemoteDataSource.swift
//  Modules
//
//  Created by Codex on 29.03.26.
//

import Alamofire
import Foundation

final class GitHubRemoteDataSource: @unchecked Sendable {
    func latestRelease<Release: Decodable>(_ type: Release.Type, complete: @escaping (Result<Release, Error>) -> Void) {
        do {
            let url = try makeRequestURL(path: .latestRelease)
            AF.request(url).responseDecodable(of: type) { response in
                guard let value = response.value else {
                    complete(.failure(response.error ?? RequestError.failed))
                    return
                }
                complete(.success(value))
            }
        } catch {
            complete(.failure(error))
        }
    }

    func releases<Release: Decodable>(_ type: Release.Type, complete: @escaping (Result<[Release], Error>) -> Void) {
        do {
            let url = try makeRequestURL(path: .releases)
            AF.request(url, parameters: ["per_page": 100]).responseDecodable(of: [Release].self) { response in
                guard let value = response.value else {
                    complete(.failure(response.error ?? RequestError.failed))
                    return
                }
                complete(.success(value))
            }
        } catch {
            complete(.failure(error))
        }
    }

    func shortcuts<T: Decodable>(_ type: T.Type, complete: @escaping (Result<T, Error>) -> Void) {
        do {
            let url = try makeRequestURL(host: .userContent, path: .shortcutsJson)
            AF.request(url).responseDecodable(of: type) { response in
                guard let value = response.value else {
                    complete(.failure(response.error ?? RequestError.failed))
                    return
                }
                complete(.success(value))
            }
        } catch {
            complete(.failure(error))
        }
    }

    func latestRelease<Release: Decodable>(_ type: Release.Type) async throws -> Release {
        let url = try makeRequestURL(path: .latestRelease)
        return try await AF.request(url)
            .serializingDecodable(type)
            .value
    }

    func releases<Release: Decodable>(_ type: Release.Type) async throws -> [Release] {
        let url = try makeRequestURL(path: .releases)
        return try await AF.request(url, parameters: ["per_page": 100])
            .serializingDecodable([Release].self)
            .value
    }

    func shortcuts<T: Decodable>(_ type: T.Type) async throws -> T {
        let url = try makeRequestURL(host: .userContent, path: .shortcutsJson)
        return try await AF.request(url)
            .serializingDecodable(type)
            .value
    }

    private func makeRequestURL(host: URLHost = .gitHubAPI, path: EndPointKinds) throws -> URL {
        var components = URLComponents()
        components.scheme = httpsScheme
        components.host = host.rawValue
        components.path = "/" + path.rawValue
        guard let url = components.url else {
            throw RequestError.invalidURL
        }
        return url
    }
}
