//
//  CustomTextField.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 10/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func prepareForInterfaceBuilder() {
        editButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editButton()
    }
    
    func editButton() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8035905394)
        layer.cornerRadius = 5.0
        textAlignment = .center
        
        if let p = placeholder {
            let place = NSAttributedString(string: p, attributes: [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)])
            attributedPlaceholder = place
            textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
        }
    }

}
