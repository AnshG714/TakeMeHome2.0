//
//  GroupCell.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 17/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    
    var nameArray = [String]()

    @IBOutlet weak var groupTitleTxt: UILabel!
    @IBOutlet weak var groupMembersTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(groupTitle: String, groupMembers: [String]) {
        DataService.instance.getFullnameList(fromUIDArray: groupMembers) { (returnedArray) in
            DispatchQueue.main.async {
                self.groupTitleTxt.text = groupTitle
                self.groupMembersTxt.text = returnedArray.joined(separator: ", ")
                self.nameArray = returnedArray
            }
        }
    }
    
}
