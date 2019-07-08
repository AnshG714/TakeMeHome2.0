//
//  Group.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 18/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import Foundation

class Group {
    private var _groupTitle: String
    private var _groupMembers: [String]
    private var _key: String
    
    var groupTitle: String {
        return _groupTitle
    }
    
    var groupMembers: [String] {
        return _groupMembers
    }
    
    var key: String {
        return _key
    }
    
    init(named title: String, withMembers members: [String], key: String) {
        self._groupTitle = title
        self._groupMembers = members
        self._key = key
    }
    
    
}
