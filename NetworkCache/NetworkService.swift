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
        return ImageCache(maxItems: 200)
    }()

    func fetchImage(urlString: String, completion: @escaping (_ result: ImageResponse) -> ()) {
        NetworkService.imageCache.get(urlString, completionBlock: { result in
            if let cachedImage = result {
                fetch(from: cachedImage, completion: { result in
                    completion(result)
                })
            } else {
                fetch(from: urlString, completion: { result in
                    completion(result)
                })
            }
        })
    }

    private func fetch(from cached: CachableImage, completion: @escaping (_ result: ImageResponse) -> ()) {
        guard let imageRequest = ImageRequest(cachedImage: cached)?.urlRequest else {
            completion(.failure(.invalidRequest))
            return
        }
        let task = NetworkService.session.dataTask(with: imageRequest, completionHandler: {
            (data, response, error) in

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 304 {
                completion(.image(cached.image))
            } else {
                self.imageFromResponseData(data: data, response: response as! HTTPURLResponse, error: error, completion: { result in
                    completion(result)
                })
            }
        })
        task.resume()
    }

    private func fetch(from urlString: String, completion: @escaping (_ result: ImageResponse) -> ()) {
        guard let imageRequest = ImageRequest(urlString: urlString)?.urlRequest else {
            completion(.failure(.invalidRequest))
            return
        }
        let task = NetworkService.session.dataTask(with: imageRequest, completionHandler: {
            (data, response, error) in

            self.imageFromResponseData(data: data, response: response as! HTTPURLResponse, error: error, completion: { result in
                completion(result)
            })
        })
        task.resume()
    }

    private func imageFromResponseData(data: Data?, response: HTTPURLResponse, error: Error?, completion: @escaping (_ result: ImageResponse) -> ()) {
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
        if let cachableImage = CachableImage(response: response, image: image) {
            DispatchQueue.global(qos: .utility).async {
            NetworkService.imageCache.write(image: cachableImage)
            }
        }
        completion(.image(image))
    }
}

