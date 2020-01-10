//
//  LoginViewController.swift
//  twitter2
//
//  Created by MacBook Pro  on 06.01.2020.
//  Copyright © 2020 MacBook Pro . All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonCotainerView: UIView!

    @IBOutlet weak var logoVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightOriginalConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightSmallerConstraint: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate


    override func viewDidAppear(_ animated: Bool) {
        logoVerticalConstraint.isActive = false
        logoTopConstraint.isActive = true
        logoHeightOriginalConstraint.isActive = true
        logoHeightSmallerConstraint.isActive = false
        UIView.animate(withDuration: 3) {
            self.view.layoutIfNeeded()
            self.buttonCotainerView.alpha = 1
            self.titleLabel.alpha = 1
            self.buttonCotainerView.frame = self.buttonCotainerView.frame.offsetBy(dx: 0, dy: -30)
            self.titleLabel.frame = self.titleLabel.frame.offsetBy(dx: 0, dy: -30)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonCotainerView.layer.cornerRadius = 5
        buttonCotainerView.alpha = 0
        titleLabel.alpha = 0
    }

    @IBAction func onloginButton() {

         //добавить внтурь метода login APIManager.shared.oauthManager.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: APIManager.shared.oauthManager)

        
        APIManager.shared.oauthManager.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: APIManager.shared.oauthManager)
        
        APIManager.shared.login { status in
            if status == true {
                self.appDelegate.userLoggedIn  = true
                self.dismiss(animated: true, completion: nil)
            }
        }


    }
}
