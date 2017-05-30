//
//  ImageRequest.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation

enum ImageRequestParameters: String {
    case ifModifiedSince = "If-Modified-Since"
    case ifNoneMatch = "If-None-Match"

    static func parameters(from cachedImage: CachableImage) -> [String: String] {
        var parameters: [String: String] = [:]
        parameters[ImageRequestParameters.ifModifiedSince.rawValue] = cachedImage.lastModified
        parameters[ImageRequestParameters.ifNoneMatch.rawValue] = cachedImage.eTag
        return parameters
    }
}

struct ImageRequest: NetworkRequest {
    let method: Method = .GET
    let baseURL: URL
    let endPoint: String
    let parameters: [String: String]?

    var urlRequest: URLRequest? {
        let URL = baseURL.appendingPathComponent(endPoint)
        guard var components = URLComponents(url: URL, resolvingAgainstBaseURL: false) else {
            return nil
        }

        if let parameters = parameters {
            components.queryItems = parameters.map { parameter, value in
                URLQueryItem(name: parameter, value: value)
            }
        }

        guard let finalURL = components.url else {
            return nil
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return request
    }

    static func urlRequest(from cachedImage: CachableImage) -> URLRequest? {
        let requestParameters = ImageRequestParameters.parameters(from: cachedImage)
        if let request = self.init(urlString: cachedImage.url, parameters: requestParameters)?.urlRequest {
            return request
        } else {
            return nil
        }
    }

    init(baseURL: URL, endPoint: String, parameters: [String: String]?) {
        self.baseURL = baseURL
        self.endPoint = endPoint
        self.parameters = parameters
    }

    init?(urlString: String, parameters: [String: String]?) {
        guard let components = URLComponents(string: urlString),
            let host = components.host,
            let base = URL(string: host)
            else {
                return nil
        }
        self.init(baseURL: base, endPoint: components.path, parameters: parameters)
    }

    init?(cachedImage: CachableImage) {
        let requestParameters = ImageRequestParameters.parameters(from: cachedImage)
        self.init(urlString: cachedImage.url, parameters: requestParameters)
    }
}







