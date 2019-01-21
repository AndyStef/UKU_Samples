//
//  GithubManager.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/18/19.
//  Copyright © 2019 AS. All rights reserved.
//

import Foundation

class GithubManager {

    // MARK: - Not very good approach

    func findRepositories(matching query: String) -> URLRequest? {
        let api = "https://api.github.com"
        let endpoint = "/search/repositories?q=\(query)"
        let url = URL(string: api + endpoint)
        guard let unwrappedUrl = url else { return nil }
        let urlRequest = URLRequest(url: unwrappedUrl)
        // TODO: - investigate URLRequest and URL params and properties

        return urlRequest
    }

//   1. As the number of parameters might grow, we'll quickly end up with quite messy code that is hard to read, since all that we're doing is adding up strings using concatenation and interpolation.
//   2. Since query is a normal string, it can contain any kind of special characters and emoji that could result in an invalid URL. We could of course encode the query using the addingPercentEncoding API, but it'd be much nicer to have the system take care of that for us.

    enum Sorting: String {
        case numberOfStars = "stars"
        case numberOfForks = "forks"
        case recency = "updated"
    }

    func findRepositories(matching query: String,
                          sortedBy sorting: Sorting) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/search/repositories"
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: sorting.rawValue)
        ]

        let _ = components.url
        // Do something further
    }
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
}

extension Endpoint {
    static func search(
        matching query: String,
        sortedBy sorting: GithubManager.Sorting = .recency
    ) -> Endpoint {
        return Endpoint(
            path: "/search/repositories",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue)
            ]
        )
    }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}

class DataLoader {
//    func request(_ endpoint: Endpoint,
//                 then handler: @escaping (Result<Data>) -> Void) {
//        guard let url = endpoint.url else {
//            return handler(.failure(Error.invalidURL))
//        }
//
//        let task = urlSession.dataTask(with: url) {
//            data, _, error in
//
//            let result = data.map(Result.success) ??
//                .failure(Error.network(error))
//
//            handler(result)
//        }
//
//        task.resume()
//    }
}

extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}
