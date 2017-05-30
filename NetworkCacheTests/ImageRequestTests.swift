//
//  ImageRequestTests.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 30/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import XCTest
@testable import NetworkCache

class ImageRequestTests: XCTestCase {
    let urlString = "https://test.com/image01.png"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testImageRequest_fromString() {
        guard let request = ImageRequest.init(urlString: urlString) else {
            XCTFail("Failed to initialise image request with url string")
            return
        }
        XCTAssertEqual(request.method, .GET)
        XCTAssertEqual(request.baseURL, URL(string: "https://test.com"))
        XCTAssertEqual(request.endPoint, "/image01.png")
        XCTAssertTrue(request.parameters == nil)
    }

    func testImageRequest_fromCachedImage() {
        let headerFields = ["last-Modified": "Wed, 24 May 2017 00:00:00 GMT", "eTag": "f7778b98fd4dfcd14fe6eaa67b73a5d0"]
        guard let url = URL(string: urlString) else {
            XCTFail()
            return
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headerFields)
        guard let cachableImage = CachableImage(response: response, image: UIImage()),
        let request = ImageRequest(cachedImage: cachableImage) else {
            XCTFail("Failed to initialise image request with url string")
        return
    }

        XCTAssertEqual(request.method, .GET)
        XCTAssertEqual(request.baseURL, URL(string: "https://test.com"))
        XCTAssertEqual(request.endPoint, "/image01.png")
        XCTAssertTrue(request.parameters?["If-Modified-Since"] == "Wed, 24 May 2017 00:00:00 GMT")
        XCTAssertTrue(request.parameters?["If-None-Match"] == "f7778b98fd4dfcd14fe6eaa67b73a5d0")
    }

}
