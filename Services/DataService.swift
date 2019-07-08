//
//  DataService.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 10/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import Foundation
import Firebase
import GoogleMaps

let DB_BASE = Database.database().reference()


class DataService {
    static let instance = DataService()
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_FRIENDS = DB_BASE.child("friends")
    private var _REF_LOCATIONS = DB_BASE.child("locations")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_FRIENDS: DatabaseReference {
        return _REF_FRIENDS
    }
    
    var REF_LOCATIONS: DatabaseReference {
        return _REF_LOCATIONS
    }
    
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func getUserEmail(forUID uid: String, handler: @escaping (_  username: String) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == uid {
                    handler(user.childSnapshot(forPath: "email").value as! String)
                }
            }
        }
    }
    
    func getUserFullname(forUID uid: String, handler: @escaping (_  username: String) -> ()) {
            self.REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
                guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for user in userSnapshot {
                    
                    if user.key == uid {
                        handler(user.childSnapshot(forPath: "fullname").value as! String)
                    }
                }
            }
    }
    
    func getFullnameList(fromUIDArray uidarr: [String], completion: @escaping (_ nameArr: [String]) -> ()){
        var namearr = [String]()

        for uid in uidarr {
            self.REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
                guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for user in userSnapshot {
                    
                    if user.key == uid {
                        namearr.append(user.childSnapshot(forPath: "fullname").value as! String)
                    }
                }
                completion(namearr)
            }
        }
    }
    
    
    func getEmail(forSearchQuery query: String, handler: @escaping (_ email: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if email.contains(query) && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            handler(emailArray)
            
        }
    }
    
    func getIds(forEmails emails: [String], handler: @escaping (_ uidArray: [String]) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            
            var idArray = [String]()
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in userSnapshot {
                if emails.contains(user.childSnapshot(forPath: "email").value as! String) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    func createGroup(withTitle title: String, forIDs ids: [String], handler: @escaping (_ groupCreated: Bool) -> ()) {
        
        let newMessage = REF_FRIENDS.childByAutoId()
        newMessage.updateChildValues(["title": title])
        let friendsGroup = newMessage.child("members")
        for uid in ids {
            friendsGroup.updateChildValues([uid: true])
        }
        handler(true)
    }
    
    func getGroups(handler: @escaping (_ groups: [Group]) -> ()) {
        REF_FRIENDS.observeSingleEvent(of: .value) { (groupSnapshot) in
            var groupArray = [Group]()
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for group in groupSnapshot {
                if (group.childSnapshot(forPath: "members").value as! [String]).contains((Auth.auth().currentUser?.uid)!) {
                    let groupTitle = group.childSnapshot(forPath: "title").value as! String
                    let groupKey = group.key
                    let groupMembers = group.childSnapshot(forPath: "members").value as! [String]
                    groupArray.append(Group(named: groupTitle, withMembers: groupMembers, key: groupKey))
                }
            }
            
            handler(groupArray)
        }
    }
    
    
    func getGroups2(handler: @escaping (_ groups: [Group]) -> ()) {
        REF_FRIENDS.observeSingleEvent(of: .value) { (groupSnapshot) in
            var groupArray = [Group]()
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for group in groupSnapshot {
                let members = group.childSnapshot(forPath: "members")
                if members.hasChild((Auth.auth().currentUser?.uid)!) {
                    let groupTitle = group.childSnapshot(forPath: "title").value as! String
                    let groupKey = group.key
                    let allmembers = members.children.allObjects as! [DataSnapshot]
                    var groupArrayWithNames = [String]()
                    for member in allmembers {
                        groupArrayWithNames.append(member.key)
                    }
                    
                    groupArray.append(Group(named: groupTitle, withMembers: groupArrayWithNames, key: groupKey))
                }
            }
            
            handler(groupArray)
        }
        
    }
    
    func uploadLocation(forUID uid: String, withLatitude lat: CLLocationDegrees, withLongitude long: CLLocationDegrees, completion: @escaping () -> ()) {
        REF_LOCATIONS.child(uid).updateChildValues(["ts": ServerValue.timestamp(), "lat": lat, "long": long])
        completion()
    }
    
    func getMemberLocations(forUID uid: String, handler: @escaping (_ returnedUserLocationArray: UserLocation?) -> ()) {
        
        REF_LOCATIONS.child(uid).observeSingleEvent(of: .value, with: { (userSnapshot) in
            if userSnapshot.hasChild("sharing") {
                if userSnapshot.childSnapshot(forPath: "sharing").value as! Bool == true {
                    let lat = userSnapshot.childSnapshot(forPath: "lat").value as! CLLocationDegrees
                    let long = userSnapshot.childSnapshot(forPath: "long").value as! CLLocationDegrees
                    let userID = uid
                    handler(UserLocation(userUID: userID, latitude: lat, longitude: long))
                }
                else {
                    handler(nil)
                }
            } else {
                handler(nil)
            }
        })
        
       
    }
    
    func exitGroup(forGroupUid groupUid: String, handler: @escaping (_ groupExitSuccessful: Bool) -> ()) {
        REF_FRIENDS.child(groupUid).child("members").child((Auth.auth().currentUser?.uid)!).removeValue()
        handler(true)
    }
    
}


