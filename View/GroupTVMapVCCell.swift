//
//  GroupListMapVCCell.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 24/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

class GroupTVMapVCCell: UITableViewCell {
    
    
    var  groupNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Avenir Next", size: CGFloat(18))
        lbl.textAlignment = .center
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let margins = self.layoutMarginsGuide
        addSubview(groupNameLabel)
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        groupNameLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        groupNameLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: CGFloat(5)).isActive = true
        groupNameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
        groupNameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
        groupNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        groupNameLabel.textAlignment = .center

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
