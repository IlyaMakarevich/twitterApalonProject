//
//  PostViewController.swift
//  twitter2
//
//  Created by Ilya Makarevich on 1/14/20.
//  Copyright © 2020 MacBook Pro . All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("postViewController shown")
    }


    @IBOutlet var textView: UITextView!

    @IBAction func postButton(_ sender: UIBarButtonItem) {
        guard let text = textView.text else {
            return
        }
        APIManager.shared.sendTweet(text: text) {result in
            if result {
                self.navigationController?.popViewController(animated: true)
            }
        }

    }
}
