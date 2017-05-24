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
    var count: Int {
        return self.accessTable.count
    }

    init(maxItems: Int) {
        cache.countLimit = maxItems
        cache.totalCostLimit = 0 // TODO: Set a limit that makes sense - this is actually the only feature why we use a cachce rather than a normal dictionary 
    }

    func get(_ imageKey: String, completionBlock: (CachableImage?) -> Void) {
        if let cachedImage = cache.object(forKey: imageKey as NSString) {
            accessTable.increaseCount(for: imageKey)
            completionBlock(cachedImage)
        } else {
            completionBlock(nil)
        }
    }

    func write(image: CachableImage) {
        prepareForUse()
        cache.setObject(image, forKey: image.url as NSString)
        accessTable.increaseCount(for: image.url)
    }

    func clearAll() {
        cache.removeAllObjects()
        accessTable.clearAll()
    }

    private func delete(objectAtKey key: String) {
        if let _ = cache.object(forKey: key as NSString) {
            accessTable.deleteEntry(for: key)
            cache.removeObject(forKey: key as NSString)
        }
    }

    private func prepareForUse() {
        while accessTable.count >= cache.countLimit {
            let deleatable = accessTable.leastAccessed
            delete(objectAtKey: deleatable)
            accessTable.deleteEntry(for: deleatable)
        }
    }
}
