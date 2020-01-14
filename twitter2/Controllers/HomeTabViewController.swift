//
//  HomeTabViewController.swift
//  twitter2
//
//  Created by Ilya Makarevich on 1/14/20.
//  Copyright © 2020 MacBook Pro . All rights reserved.
//

import UIKit

class HomeTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setupTabBarController() {
        view.backgroundColor = .green
        guard let homeImage = UIImage(named: "home") else {return}
        let viewController1 = createNavController(vc: ProfileViewController(), title: "Modal", image:homeImage)

        guard let newsImage = UIImage(named: "news") else {return}
        let viewController2 = createNavController(vc: TimeLineViewController(), title: "Stack", image:newsImage)

        addChild(viewController1)
        addChild(viewController2)
    }

}

extension UIViewController {
    func createNavController(vc: UIViewController, title: String, image: UIImage) -> UINavigationController {
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
