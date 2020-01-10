//
//  SplashViewController.swift
//  twitter2
//
//  Created by MacBook Pro  on 06.01.2020.
//  Copyright © 2020 MacBook Pro . All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, TwitterLoginDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if APIManager.shared.checkAccessToken() {
            self.performSegue(withIdentifier: "TabSegue", sender: self)
        } else if !(appDelegate.userLoggedIn) {
            self.continueLogin()
        }
        
    }
    
    func continueLogin() {
        appDelegate.userLoggedIn = false
        self.goToLogin()
    }
    
    func goToLogin() {
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    
    
}
