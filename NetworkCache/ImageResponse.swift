//
//  ImageResponse.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation
import UIKit

enum ImageResponse {
    case image(UIImage)
    case inCache
    case failure(Errors)
}

enum ImageResponseParameters: String {
    case lastModified = "Last-Modified"
    case eTag = "Etag"
}
