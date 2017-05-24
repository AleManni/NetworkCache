//
//  ImageCache.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation
import UIKit

protocol Cache {
    func get(_ imageURLString: String, completionBlock: (CachableImage?) -> Void)
}

class ImageCache: Cache {
    private let cache = NSCache<NSString, CachableImage>()
    private var accessTable = AccessTable()

    init(maxItems: Int) {
        cache.countLimit = maxItems
        cache.totalCostLimit = 10 // TODO: Set a limit that makes sense
    }

    func get(_ imageURLString: String, completionBlock: (CachableImage?) -> Void) {
        if let cachedImage = cache.object(forKey: imageURLString as NSString) {
            accessTable.increaseCount(for: imageURLString)
            completionBlock(cachedImage)
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

    func write(image: CachableImage) {
        cache.setObject(image, forKey: image.url as NSString)
        accessTable.increaseCount(for: image.url)
    }
}
