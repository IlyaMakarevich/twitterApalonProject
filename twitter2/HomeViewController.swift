//
//  ProfileViewController.swift
//  twitter2
//
//  Created by MacBook Pro  on 22.12.2019.
//  Copyright © 2019 MacBook Pro . All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire


class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var folowersButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var getInfoButton: UIButton!
    @IBOutlet weak var getTimelineLabel: UIButton!
    @IBOutlet weak var getRelationsLabel: UIButton!
    var user = User(name: "")
    let defaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileButton.isEnabled = false
        APIManager.shared.retrieveCredentials()
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateLabels()
    }
    
    @IBAction func getInfoTapped(_ sender: Any) {
        APIManager.shared.verifyCredentials()
    }
    
    
    @IBAction func getRelationsTapped(_ sender: Any) {
        APIManager.shared.getRelations()
    }
    
    @IBAction func followersTapped(_ sender: Any) {
        APIManager.shared.showFollowers()
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        APIManager.shared.oauthManager.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: APIManager.shared.oauthManager)
        
        APIManager.shared.login { name in
            self.defaults.set(name, forKey: "screen_name")
            self.updateLabels()
        }
    }
    
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        APIManager.shared.logOut {
            self.updateLabels()
        }
    }
    
    
    
    @IBAction func getTimelineTapped(_ sender: Any) {
        APIManager.shared.getTimeline { (tweet) in
            print(tweet)
        }
    }
    
    func updateLabels() {
        getInfoButton.isEnabled = true
        folowersButton.isEnabled = false
        getTimelineLabel.isEnabled = false
        getRelationsLabel.isEnabled = false
        loginButton.isEnabled = true
        idLabel.isHidden = true
        if APIManager.shared.checkAccessToken() {
            folowersButton.isEnabled = true
            loginButton.isEnabled = false
            getTimelineLabel.isEnabled = true
            getRelationsLabel.isEnabled = true
            idLabel.isHidden = false
            idLabel.text = ("signed in: \(self.defaults.string(forKey: "screen_name") ?? "not signed in!")")
            profileButton.isEnabled = true
        }
    }
}

enum JSONError: Error {
    case parsing(String)
}
