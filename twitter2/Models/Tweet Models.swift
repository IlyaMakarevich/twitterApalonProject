//
//  Tweet.swift
//  twitter2
//
//  Created by MacBook Pro  on 02.01.2020.
//  Copyright © 2020 MacBook Pro . All rights reserved.
//

import Foundation

struct TweetDecodable: Decodable{

    var id_str: String
    var createdAt: String
    var text: String

    var profileImageUrl: String
    var name: String
    var screenName: String
    
    enum TweetJsonRootKeys: String, CodingKey {
        case id_str
        case createdAt = "created_at"
        case text
        case user
    }
    
    enum UserJsonKeys: String, CodingKey {
        case profileImageUrl = "profile_image_url"
        case name
        case screenName = "screen_name"
    }

    init(from decoder: Decoder) throws {
        print("Init from decoder")
        let rootContainer = try decoder.container(keyedBy: TweetJsonRootKeys.self)
        self.id_str = try rootContainer.decode(String.self, forKey: .id_str)
        self.createdAt = try rootContainer.decode(String.self, forKey: .createdAt)
        self.text = try rootContainer.decode(String.self, forKey: .text)
        let userContainer = try rootContainer.nestedContainer(keyedBy: UserJsonKeys.self, forKey: .user)
        self.profileImageUrl = try userContainer.decode(String.self, forKey: .profileImageUrl)
        self.name = try userContainer.decode(String.self, forKey: .name)
        self.screenName = try userContainer.decode(String.self, forKey: .screenName)
    }
}

struct TweetStruct {

    var id_str: String
    var createdAt: String
    var text: String

    var profileImageUrl: String
    var name: String
    var screenName: String

}



/*

struct Tweet2: Decodable {

    var id: Double
    var text: String
    var created_at: String

    var screen_name: String
    var name: String
    var profile_image_url: String

    
    enum CodingKeys: String, CodingKey {
        case id
        case created_at
        case text
        case user
    }
    
    enum UserCodingKeys: String, CodingKey {
        case name = "name"
        case screen_name = "screen_name"
        case profile_image_url
    }
    
    
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.created_at = try container.decode(String.self, forKey: .created_at)
        self.text = try container.decode(String.self, forKey: .text)
        self.id = try container.decode(Double.self, forKey: .id)
        
        // Nested user{}
        let userContainer = try container.nestedContainer(keyedBy: UserCodingKeys.self, forKey: .user)
        self.name = try userContainer.decode(String.self, forKey: .name)
        self.screen_name = try userContainer.decode(String.self, forKey: .screen_name)
        self.profile_image_url = try userContainer.decode(String.self, forKey: .profile_image_url)
    }
}

*/
//struct Tweet3 {
//
//    let text: String?
//    let created_at: String?
//
//    let user_data: (screen_name: String, name: String, profile_image_url: String)
//}
//
//extension Tweet3 {
//
//    init?(json: [String: Any]) {
//        guard let text = json["text"] as? String,
//            let created_at = json["created_at"] as? String,
//            let user_data = json["user"] as? [String: String],
//            let screen_name = user_data["screen_name"],
//            let name = user_data["name"],
//            let profile_image_url = user_data["profile_image_url"]
//            else {
//                return nil
//        }
//
//
//        self.text = text
//        self.created_at = created_at
//        self.user_data = (screen_name, name, profile_image_url)
//
//}
//}


