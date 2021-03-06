//
//  APIManager.swift
//  twitter2
//
//  Created by MacBook Pro  on 27.12.2019.
//  Copyright © 2019 MacBook Pro . All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift
import KeychainAccess

class APIManager: SessionManager{
    
    static var shared: APIManager = APIManager()
    var oauthManager : OAuth1Swift!
    var handle: OAuthSwiftRequestHandle?
    var credentials = OAuthSwiftCredential(consumerKey: Keys.twitterConsumerKey, consumerSecret: Keys.twitterSecretKey)
    let homeVC = HomeViewController()
    let loginVC = LoginViewController()
    var tweets = [TweetStruct]()
    let defaults = UserDefaults.standard
    let loggedInUser = User(userDict: ["":""])

        
    private init () {
        super.init()
        //create instance
        oauthManager = OAuth1Swift(
            consumerKey:    Keys.twitterConsumerKey,
            consumerSecret: Keys.twitterSecretKey,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        
        // Retrieve access token from keychain if it exists
        if let credential = retrieveCredentials() {
            oauthManager.client.credential.oauthToken = credential.oauthToken
            print(credential.oauthToken)
            oauthManager.client.credential.oauthTokenSecret = credential.oauthTokenSecret
            print(credential.oauthTokenSecret)
        }
    }

    
    //Twitter api methods

    func login(completion: @escaping (Bool) -> ()) {

       

        handle = oauthManager.authorize(
        withCallbackURL: URL(string: "twitter2://oauth-callback/twitter")!) { result in
            switch result {
            case .success(let (credential,_,parameters)):
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                if let user_id = parameters["user_id"] as? String {
                    self.defaults.set(user_id, forKey: "user_id")
                }
                self.saveCredenitalsInKeychain(credential: credential)
                completion(true)
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }       
    }
    
    func getProfileInfo(completion: @escaping(User) -> ()) {
        handle = oauthManager.client.get("https://api.twitter.com/1.1/account/verify_credentials.json") { results in
            switch results {
            case .success(let response):
                let jsonDict = try? response.jsonObject() as? [String: Any]
                let user = User(userDict: jsonDict!)
                completion(user)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getRelations(){
        print("getting relations")
        guard let user_id = defaults.string(forKey: "user_id") else {return}

        handle = oauthManager.client.get("https://api.twitter.com/1.1/friendships/lookup.json", parameters: ["user_id": user_id]) { results in
            
            switch results {
            case .success(let response):
                let jsonDict = try? response.jsonObject()
                print(String(describing: jsonDict))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func showFollowers() {
        guard let user_id = defaults.string(forKey: "user_id") else {return}
        handle = oauthManager.client.get("https://api.twitter.com/1.1/followers/ids.json",  parameters: ["screen_name": user_id]) { results in
            
            switch results {
            case .success(let response):
                let jsonDict = try? response.jsonObject()
                print(String(describing: jsonDict))
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func getTimeline(page: Int=1, completion: @escaping ([TweetStruct]) -> Void) {

        handle = oauthManager.client.get("https://api.twitter.com/1.1/statuses/home_timeline.json", parameters: ["count": 20 * page,  "exclude_replies" : "true"]) { results in
            
            switch results {
            case .success(let response):
                if let tweetsFromJSON = try? JSONDecoder().decode([TweetDecodable].self, from: response.data) {
                    print(tweetsFromJSON)
                    self.tweets = tweetsFromJSON.map ({
                        TweetStruct(id_str: $0.id_str, createdAt: $0.createdAt,
                        text: $0.text, profileImageUrl: $0.profileImageUrl,
                        name: $0.name, screenName: $0.screenName)
                    })
                    completion(self.tweets)
                }

            case .failure(let error):
                print(error)
            }
            
        }
    }
    func getTimelineWithId(page: Int=1, id:String = "", completion: @escaping ([TweetStruct]) -> Void) {

        handle = oauthManager.client.get("https://api.twitter.com/1.1/statuses/home_timeline.json", parameters: ["count": 20 * page,  "exclude_replies" : "true", "max_id" : id]) { results in

            switch results {
            case .success(let response):
                if let tweetsFromJSON = try? JSONDecoder().decode([TweetDecodable].self, from: response.data) {
                    print(tweetsFromJSON)
                    self.tweets = tweetsFromJSON.map ({
                        TweetStruct(id_str: $0.id_str, createdAt: $0.createdAt,
                        text: $0.text, profileImageUrl: $0.profileImageUrl,
                        name: $0.name, screenName: $0.screenName)
                    })
                    completion(self.tweets)
                }

            case .failure(let error):
                print(error)
            }

        }
    }
    
    func getUserTimeline(completion: @escaping ([TweetStruct]) -> Void) {
 
        guard let user_id = defaults.string(forKey: "user_id") else {return}
        
        handle = oauthManager.client.get("https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: ["count": 20,  "user_id": user_id]) { results in
            
            switch results {
            case .success(let response):
                if let tweetsFromJSON = try? JSONDecoder().decode([TweetDecodable].self, from: response.data) {
                    print(tweetsFromJSON)
                    self.tweets = tweetsFromJSON.map ({
                        TweetStruct(id_str: $0.id_str, createdAt: $0.createdAt,
                        text: $0.text, profileImageUrl: $0.profileImageUrl,
                        name: $0.name, screenName: $0.screenName)
                    })
                    completion(self.tweets)
                }

            case .failure(let error):
                print(error)
            }
            
        }
    }

    func sendTweet(text: String, completion: @escaping(Bool) ->()) {
        handle = oauthManager.client.post("https://api.twitter.com/1.1/statuses/update.json", parameters: ["status" : text])
        { (results) in
            switch results {
            case .success(let response):
                print(response)
                completion(true)

            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }

    
    func logOut(completion: @escaping () -> ()) {
        // create the alert
        let alertController = UIAlertController(title: "Log out", message: "Clear token from userdefaults?", preferredStyle: .alert)

        let clearAction = UIAlertAction(title: "Clear token", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.clearCredentials()
            completion()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }

        alertController.addAction(cancelAction)
        alertController.addAction(clearAction)

        topMostController().present(alertController, animated: true, completion: nil)
    }

    
    // MARK: Save Tokens in Keychain
    func saveCredenitalsInKeychain(credential: OAuthSwiftCredential) {
        let keychain = Keychain()
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)


        keychain[data: "twitter_credentials"] = data
    }
    
    
    // MARK: Retrieve Credentials
    func retrieveCredentials() -> OAuthSwiftCredential? {
        let keychain = Keychain()
        if let data = keychain[data: "twitter_credentials"] {
            credentials = NSKeyedUnarchiver.unarchiveObject(with: data) as! OAuthSwiftCredential
            return credentials
        } else {
            return nil
        }
    }
    
    // MARK: Clear tokens in Keychain
    func clearCredentials() {
        // Store access token in keychain
        let keychain = Keychain()
        do {
            try keychain.remove("twitter_credentials")
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func checkAccessToken() -> Bool {
        let keychain = Keychain()
        if let data = keychain[data: "twitter_credentials"] {
            return true
        } else {
            return false
        }
    }
    
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
}

