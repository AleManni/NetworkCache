//
//  NetworkService.swift
//  NetworkCache
//
//  Created by Alessandro Manni on 24/05/2017.
//  Copyright © 2017 Alessandro Manni. All rights reserved.
//

import Foundation
import UIKit


class NetworkService {

    private static var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 10.0
        let session = URLSession(configuration: configuration)
        return session
    }()

    private static var imageCache: NSCache = {
        return NSCache<NSString, CachableImage>()
        // Initialise the chace properly once you have created its class
    }()

    func fetchImage(urlString: String, completion: @escaping (_ result: ImageResponse) -> ()) {

        guard let imageRequest = imageRequest(urlString) else {
            completion(.failure(.invalidRequest))
            return
        }

        let task = NetworkService.session.dataTask(with: imageRequest, completionHandler: {
            (data, response, error) in
            if let error = error as NSError? {
                completion(.failure(.networkError(error)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, let urlString = imageRequest.url?.absoluteString, httpResponse.statusCode == 304 {
                // chache retrieves image with urlString key and returns it
            } else {
                guard let responseData = data else {
                    completion(.failure(.noData))
                    return
                }
                guard let image = UIImage(data: responseData) else {
                    completion(.failure(.dataError))
                    return
                }
                if let cachableImage = CachableImage(url: imageRequest.url, response: response as? HTTPURLResponse, image: image) {
                    // static cache store the cachableImage - dispatch in background queue
                }
                completion(.image(image))
            }
        })
        task.resume()
    }

    private func imageRequest(_ urlString: String) -> URLRequest? {
        var requestParameters: [String: String]?
        if let cachedImage = NetworkService.imageCache.object(forKey: urlString as NSString) {
            requestParameters = ImageRequestParameters.parameters(from: cachedImage)
        }
        guard let url = URL(string: urlString), let imageRequest = ImageRequest(baseURL: url, endPoint: nil, parameters: requestParameters).urlRequest else {
            return nil
        }
        return imageRequest
    }
}

