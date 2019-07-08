//
//  GroupPopupVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 01/07/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

class GroupPopupVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var groupNameTableView: UITableView!
    @IBOutlet var mainView: UIView!
    
    var memberNames = [String]()
    var currentGroupID = ""
    let alert = UIAlertController(title: "Exit Group?", message: "", preferredStyle: .alert)
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = groupNameTableView.dequeueReusableCell(withIdentifier: "PopupCell", for: indexPath) as? PopupCell else { return PopupCell() }
        cell.configureCell(withMemberName: self.memberNames[indexPath.row])
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        groupNameTableView.delegate = self
        groupNameTableView.dataSource = self
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPopup)))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
        }))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { (alertAction) in
            DataService.instance.exitGroup(forGroupUid: self.currentGroupID) { (success) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }))
        
    }
    
    @IBAction func didTapExitButton(_ sender: Any) {
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    

}
