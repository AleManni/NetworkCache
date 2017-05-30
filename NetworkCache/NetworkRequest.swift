//
//  NetworkRequest.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation

enum Method: String {
    case GET = "GET"
    // We don't need all the cases for this test
}

protocol NetworkRequest {
    var method: Method { get }
    var baseURL: URL { get }
    var endPoint: String { get }
    var parameters: [String: String]? { get }
    var urlRequest: URLRequest? { get }
}

