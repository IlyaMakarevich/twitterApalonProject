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
        frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        layer.cornerRadius = bounds.size.width / 2
        setImage(UIImage(named: "pencil-2"), for: .normal)
        backgroundColor = .systemPink
    }


}
