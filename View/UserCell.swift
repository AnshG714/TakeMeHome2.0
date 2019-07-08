//
//  UserCell.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 17/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var emailTxt: UILabel!
    var cellSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(withEmail email: String, isSelected: Bool) {
        self.emailTxt.text = email
        if isSelected {
            contentView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
            if cellSelected == true {
                contentView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                cellSelected = false
            } else {
                contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cellSelected = true
            }
    }
    
    

}
