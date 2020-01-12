//
//  User.swift
//  twitter2
//
//  Created by MacBook Pro  on 09.01.2020.
//  Copyright © 2020 MacBook Pro . All rights reserved.
//

import UIKit

class User {
   
    let userDict: [String: Any]!
    let id: UInt?
    let name: String!
    let screen_name: String!
    let description: String?
    let profile_banner_url_string: String?
    let profile_image_url_string: String?
    let followers_count: Int?
    
    init(userDict: [String: Any]) {
        self.userDict = userDict
        self.id = userDict["id"] as? UInt
        self.name = userDict["name"] as? String
        self.screen_name = userDict["screen_name"] as? String
        self.description = userDict["description"] as? String
        self.profile_banner_url_string = userDict["profile_banner_url"] as? String
        self.profile_image_url_string = userDict["profile_image_url"] as? String
        self.followers_count = userDict["followers_count"] as? Int
    }
}
