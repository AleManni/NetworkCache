//
//  NetworkCacheTests.swift
//  NetworkCacheTests
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import XCTest
@testable import NetworkCache

class NetworkCacheTests: XCTestCase {
    var cache = ImageCache(maxItems: 20)
    let mockGenerator = MocksGenerator()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        cache.clearAll()
    }

    func testCachableImage() {
        guard let url = URL(string: "https://test") else {
            XCTFail()
            return
        }
        let headerFields = ["last-Modified": "Wed, 24 May 2017 00:00:00 GMT", "eTag": "f7778b98fd4dfcd14fe6eaa67b73a5d0"]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headerFields)
        let cachableImage = CachableImage(response: response, image: UIImage())
        XCTAssertEqual(cachableImage?.eTag, "f7778b98fd4dfcd14fe6eaa67b73a5d0")
        XCTAssertEqual(cachableImage?.lastModified, "Wed, 24 May 2017 00:00:00 GMT")
        XCTAssertEqual(cachableImage?.url, url.absoluteString)
        XCTAssertEqual(UIImagePNGRepresentation(cachableImage!.image), UIImagePNGRepresentation(UIImage()))
    }

    func testCacheWrite() {
        cache.add(mocks: 20)
        XCTAssertEqual(cache.count, 20, "Expected 20, returned \(cache.count)")
    }

    func testCacheOverMaxCount() {
        cache.add(mocks: 30)
        XCTAssertEqual(cache.count, 20, "Expected 20, returned \(cache.count)")
    }

    func testCacheRetrieve() {
        let mockGenerator = MocksGenerator()
        let responses = mockGenerator.responses(20)
        let cachables = mockGenerator.cachableImages(responses: responses)
        cache.add(mocks: cachables)
        cache.get(cachables[0].url, completionBlock: { result in
            XCTAssertEqual(cachables[0], result)
        })
    }

    func testCancellationPolicy() {
        // GIVEN
        let cachables = mockGenerator.cachableImages(19)
        let extraElement1 = mockGenerator.cachableImages(1)[0]
        let extraElement2 = mockGenerator.cachableImages(2)[0]

        cache.add(mocks: cachables)
        cachables.forEach {
            cache.get($0.url, completionBlock: { result in
            })
        }
        cache.write(image: extraElement1)
        //WHEN
        cache.write(image: extraElement2)
        // THEN
        // extraElement1 is expected to be replaced by extraElement2
        cache.get(extraElement1.url, completionBlock: { result in
            XCTAssertFalse(result != nil, "The least accessed element was expected to be replaced by the new element when overcount")
        })
        // extraElement2 is expected to be in cache
        cache.get(extraElement2.url, completionBlock: { result in
            XCTAssertTrue(result == extraElement2, "extraElement2 was expected to be cached")
        })
    }

        func testCacheClearAll() {
            let cachables = mockGenerator.cachableImages(20)
            cache.add(mocks: cachables)
            XCTAssertEqual(cache.count, cachables.count)
            cache.clearAll()
            XCTAssertEqual(cache.count, 0, "Cache should have been emptied but it still holds \(cache.count) elements")
        }
}
