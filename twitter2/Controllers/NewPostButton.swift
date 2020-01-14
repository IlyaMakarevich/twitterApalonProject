//
//  NewPostButton.swift
//  twitter2
//
//  Created by MacBook Pro  on 13.01.2020.
//  Copyright © 2020 MacBook Pro . All rights reserved.
//

import UIKit


class NewPostButton: UIButton {

    override init (frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        setImage(UIImage(named: "pencil-2"), for: .normal)
        frame = CGRect(x: 200,y: 200,width: 50,height: 50)
        layer.cornerRadius = layer.frame.width / 2
        layer.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor

        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 10.0
        layer.masksToBounds = false
    }
}

extension UIButton {
   func press(completion:@escaping ((Bool) -> Void)) {
            UIView.animate(withDuration: 0.05, animations: {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) }, completion: { (finish: Bool) in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.transform = CGAffineTransform.identity
                        completion(finish)
                    })
            })
    }
}
