//
//  GroupsVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 17/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

class GroupsVC: UIViewController {
    
    
    @IBOutlet weak var _tableView: UITableView!
    
    var groupsArray = [Group]()
    var nameArrayToPass = [String]()
    let blackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _tableView.delegate = self
        _tableView.dataSource = self
        // Do any additional setup after loading the view
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.REF_FRIENDS.observe(.value) { (snapshot) in
            DataService.instance.getGroups2(handler: { (returnedGroupArray) in
                self.groupsArray =  returnedGroupArray
                MapVC.groupsArray = self.groupsArray
                self._tableView.reloadData()
            })
        }
    }

}

extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as? GroupCell else { return GroupCell() }
        
        let group = groupsArray[indexPath.row]

        cell.configureCell(groupTitle: group.groupTitle, groupMembers: group.groupMembers)
           
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        print("selected")

        let popOver = self.storyboard?.instantiateViewController(withIdentifier: "GroupPopupVC") as? GroupPopupVC
        let cell = _tableView.cellForRow(at: indexPath) as? GroupCell
        popOver?.memberNames = (cell?.nameArray)!
        popOver?.currentGroupID = groupsArray[indexPath.row].key
        popOver?.preferredContentSize = CGSize(width: 0.9*view.frame.width, height: 350)
        popOver?.modalPresentationStyle = .overCurrentContext
        popOver?.modalTransitionStyle = .crossDissolve
        present(popOver!, animated: true, completion: nil)
    }
    
}
