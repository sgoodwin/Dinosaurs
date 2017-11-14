//
//  Fetch.swift
//  Dinosaurs
//
//  Created by Samuel Ryan Goodwin on 11/14/17.
//  Copyright © 2017 Roundwall Software. All rights reserved.
//

import Foundation

struct Fetch<T: Decodable> {
    let path: String
    let queryItems: [URLQueryItem]
    
    func fetch(completion: @escaping (T) -> ()) {
        var loginComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        loginComponents.queryItems = queryItems
        let loginTask = session.dataTask(with: loginComponents.url!) { (data, response, error) in
            guard let data = data else {
                print(error ?? "No error, but also no data")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let info = try decoder.decode(T.self, from: data)
                completion(info)
            } catch {
                print(error.localizedDescription)
            }
        }
        loginTask.resume()
    }
}
