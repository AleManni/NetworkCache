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

    private static var imageCache: ImageCache = {
        return ImageCache(maxItems: 20)
    }()

    func fetchImage(urlString: String, completion: @escaping (_ result: ImageResponse) -> ()) {
        NetworkService.imageCache.get(urlString, completionBlock: { result in
            if let cachedImage = result {
                fetchFromCache(cached: cachedImage, completion: { result in
                    completion(result)
                })
            } else {
                fetch(urlString: urlString, completion: { result in
                    completion(result)
                })
            }
        })
    }

    func fetchFromCache(cached: CachableImage, completion: @escaping (_ result: ImageResponse) -> ()) {
        guard let imageRequest = imageRequest(cached) else {
            completion(.failure(.invalidRequest))
            return
        }
        let task = NetworkService.session.dataTask(with: imageRequest, completionHandler: {
            (data, response, error) in
            if let error = error as NSError? {
                completion(.failure(.networkError(error)))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 304 {
                completion(.image(cached.image))
            } else {
                completion(.failure(.cacheError))
            }
        })
        task.resume()
    }

    func fetch(urlString: String, completion: @escaping (_ result: ImageResponse) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidRequest))
            return
        }
        guard let imageRequest = ImageRequest(baseURL: url, endPoint: nil, parameters: nil).urlRequest else {
            completion(.failure(.invalidRequest))
            return
        }
        let task = NetworkService.session.dataTask(with: imageRequest, completionHandler: {
            (data, response, error) in
            if let error = error as NSError? {
                completion(.failure(.networkError(error)))
                return
            }
            guard let responseData = data else {
                completion(.failure(.noData))
                return
            }
            guard let image = UIImage(data: responseData) else {
                completion(.failure(.dataError))
                return
            }
            if let cachableImage = CachableImage(url: imageRequest.url, response: response as? HTTPURLResponse, image: image) {
                NetworkService.imageCache.write(image: cachableImage)
            }
            completion(.image(image))
        })
        task.resume()
    }

    private func imageRequest(_ cachedImage: CachableImage) -> URLRequest? {
        let requestParameters = ImageRequestParameters.parameters(from: cachedImage)
        guard let url = URL(string: cachedImage.url), let imageRequest = ImageRequest(baseURL: url, endPoint: nil, parameters: requestParameters).urlRequest else {
            return nil
        }
        return imageRequest
    }
}

