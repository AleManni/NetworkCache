//
//  Utilities.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation
import UIKit
@testable import NetworkCache

// MARK: - Other utils functions

func randomString(withLength length: Int) -> String {

    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

class MocksGenerator {

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        return formatter
    }()

    func responses(_ numberOfResponses: Int) -> [HTTPURLResponse] {
        var responses: [HTTPURLResponse] = []
        for _ in 1...numberOfResponses {
            let urlString = "https://" + randomString(withLength: 8)
            guard let url = URL(string: urlString) else {
                break
            }
            let date = Date()
            let dateString = dateFormatter.string(from: date)
            let headerFields: [String: String] = [ImageResponseParameters.lastModified.rawValue: dateString, ImageResponseParameters.eTag.rawValue: randomString(withLength: 8)]
            if let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headerFields) {
                responses.append(response)
            }
        }
        return responses
    }

    func cachableImages(responses: [HTTPURLResponse]) -> [CachableImage] {
        let cachables = responses.map {
            CachableImage(response: $0, image: UIImage())
        }
        return cachables.flatMap { $0 }
    }

    func cachableImages(_ number: Int) -> [CachableImage] {
        let responses = self.responses(number)
        return cachableImages(responses: responses)
    }
}

extension ImageCache {

    func add(mocks number: Int) {
        let mockGenerator = MocksGenerator()
        let responses = mockGenerator.responses(20)
        let cachables = mockGenerator.cachableImages(responses: responses)
        add(mocks: cachables)
    }

    func add(mocks mocksArray: [CachableImage]) {
        mocksArray.forEach {
            write(image: $0)
        }
    }
}
