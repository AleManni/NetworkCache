//
//  Errors.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation

enum Errors: Error {
    case invalidRequest
    case dataError
    case noData
    case networkError(Error)
}

extension Errors: CustomStringConvertible {

    public var description: String {
        switch self {
        case .invalidRequest:
            return "The URLRequest is not valid"
        case .noData:
            return "No data returned form server"
        case .dataError:
            return "Response from server cannot be converted in image"
        case .networkError(let error):
            return (error.localizedDescription)
        }
    }
}
