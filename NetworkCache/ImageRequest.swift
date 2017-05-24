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
    var method: Method = .GET
    var baseURL: URL
    var endPoint: String?
    var parameters: [String: String]?
    var urlRequest: URLRequest? {
        let URL = baseURL.appendingPathComponent(endPoint ?? "")
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

    init(baseURL: URL, endPoint: String?, parameters: [String: String]?) {
        self.baseURL = baseURL
        self.endPoint = endPoint
        self.parameters = parameters
    }
    
}







