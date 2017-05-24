//
//  ImageCache.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation
import UIKit

protocol MySuperCache {
    func get(imageAtURLString imageURLString: String, completionBlock: (UIImage?) -> Void)
}

class ImageCache: MySuperCache {
    private let cache = NSCache<NSString, CachableImage>()
    private var accessTable = AccessTable()

    init(maxItems: Int) {
        cache.countLimit = maxItems
        cache.totalCostLimit = 10 // TODO: Set a limit that makes sense
    }

    func get(imageAtURLString imageURLString: String, completionBlock: (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: imageURLString as NSString) {
            accessTable.increaseCount(for: imageURLString)
            completionBlock(cachedImage.image)
        } else {
            completionBlock(nil)
        }
    }

    private func delete(objectAtKey key: String) {
        if let _ = cache.object(forKey: key as NSString) {
            accessTable.deleteEntry(for: key)
            cache.removeObject(forKey: key as NSString)
        }
    }

    private func prepareForUse() {
        while accessTable.count >= cache.countLimit {
            delete(objectAtKey: accessTable.leastAccessed)
        }
    }

    func write(image: CachableImage, urlString: String) {
        cache.setObject(image, forKey: urlString as NSString)
        accessTable.increaseCount(for: urlString)
    }
}
