//
//  Post.swift
//  PostiOS22
//
//  Created by Porter Frazier on 10/15/18.
//  Copyright © 2018 BULB. All rights reserved.
//

import Foundation


struct Post: Codable {
    
    
    var text: String
    var username: String
    var timestamp: TimeInterval = TimeInterval()
    
    init(text: String, username: String) {
        
        self.text = text
        self.username = username
        self.timestamp = Date().timeIntervalSince1970
    }
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
}

