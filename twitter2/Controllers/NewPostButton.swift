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
        layer.backgroundColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
}
