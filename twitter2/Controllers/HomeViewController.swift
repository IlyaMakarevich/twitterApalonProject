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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate


    
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
            self.updateLabels()
        }
    }
    
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        APIManager.shared.logOut {
            self.updateLabels()
            self.dismiss(animated: true, completion: nil)
            self.appDelegate.userLoggedIn = false
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
            idLabel.text = ("signed in: \(defaults.string(forKey: "user_id") ?? "not signed in!")")
            
            profileButton.isEnabled = true
        }
    }
}

enum JSONError: Error {
    case parsing(String)
}
