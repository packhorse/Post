//
//  PostController.swift
//  PostiOS22
//
//  Created by Porter Frazier on 10/15/18.
//  Copyright © 2018 BULB. All rights reserved.
//

import Foundation

class PostController: Codable {
    
    static var posts: [Post] = []
    
    
    static let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")!
    static let getterEndpoint = baseURL.appendingPathExtension("json")
    
    
    //Step #1: Construct the URL.
    static func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : PostController.posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        var urlComponents = URLComponents(url: PostController.baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return }
        
        let getterEndpoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            
            if let error = error {
                NSLog("There was an error retrieving data in \(#function). Error: \(error)")
                completion()
                return
            }
            
            guard let data = data else { NSLog("No returned from data task."); completion();  return }
            
            do {
                let decoder = JSONDecoder()
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                var posts: [Post] = postsDictionary.compactMap( { $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    posts = sortedPosts
                } else {
                   posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch let error {
                NSLog("error decoding: \(error), \(error.localizedDescription)")
                completion()
            }
        })
        dataTask.resume()
    }
    
    
    static func addPost(username: String, text: String, completion: @escaping() -> Void) {
        
        let post = Post(text: text, username: username)
        
        var postData: Data
        
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch let error {
            NSLog("error encoding post to be saved: \(error.localizedDescription)")
            completion()
            return
        }
        
        let postEndpoint = PostController.baseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: postEndpoint)
        
        request.httpMethod = "POST"
        
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error { completion(); NSLog(error.localizedDescription) }
            
            guard let data = data,
                let _ = String(data: data, encoding: .utf8)
                else { NSLog("No data could be lodaded to the base.");
                    completion()
                    return }
            
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
    
}
