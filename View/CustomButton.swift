//
//  CustomButton.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 10/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 7.0
    }

}
