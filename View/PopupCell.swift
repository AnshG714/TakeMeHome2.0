//
//  PopupCell.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 01/07/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

class PopupCell: UITableViewCell {
    @IBOutlet weak var nameText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(withMemberName name: String) {
        nameText.text = name
    }
}
