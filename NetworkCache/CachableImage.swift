//
//  CachableImage.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation
import UIKit

class CachableImage {
    let url: String
    let lastModified: String
    let eTag: String
    let image: UIImage

    init(urlString: String, last: String, tag: String, image: UIImage) {
        url = urlString
        lastModified = last
        eTag = tag
        self.image = image
    }

    convenience init?(response: HTTPURLResponse?, image: UIImage) {
        if let httpResponse = response,
            let urlString = response?.url?.absoluteString,
            let lastModified = httpResponse.allHeaderFields[ImageResponseParameters.lastModified.rawValue] as? String,
            let eTag = httpResponse.allHeaderFields[ImageResponseParameters.eTag.rawValue] as? String {
            self.init(urlString: urlString,
                      last: lastModified,
                      tag: eTag,
                      image: image
            )} else {
            return nil
        }
    }
}

extension CachableImage: Equatable {
    public static func == (lhs: CachableImage, rhs: CachableImage) -> Bool {
        return lhs.url == rhs.url
            && lhs.lastModified == rhs.lastModified
            && lhs.eTag == rhs.eTag
            && UIImagePNGRepresentation(lhs.image) == UIImagePNGRepresentation(rhs.image)
    }
}

