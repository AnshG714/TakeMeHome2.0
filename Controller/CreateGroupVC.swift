//
//  CreateGroupVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 17/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateGroupVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailSearchTextField: UITextField!
    @IBOutlet weak var groupNameTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var groupMembersTxt: UILabel!
    
    var emailArray = [String]()
    var chosenEmailArray = [String]()
    
    let alert = UIAlertController(title: "Maximum group limit reached", message: "You cannot add more than 4 members to a group", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Back", style: .cancel) { (alertAction) in
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailSearchTextField.delegate = self
        emailSearchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.allowsMultipleSelection = true
        
        alert.addAction(cancelAction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.isHidden = true
    }
    
    @objc func textFieldDidChange() {
        if emailSearchTextField.text == "" {
            emailArray = []
            tableView.reloadData()
        } else {
            DataService.instance.getEmail(forSearchQuery: emailSearchTextField.text!, handler: { (returnedEmailArray) in
                self.emailArray = returnedEmailArray
                self.tableView.reloadData()
            })
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        DataService.instance.getIds(forEmails: chosenEmailArray) { (returnedidArray) in
            var idArray = returnedidArray
            idArray.append((Auth.auth().currentUser?.uid)!)
            
            DataService.instance.createGroup(withTitle: self.groupNameTxt.text!, forIDs: idArray, handler: { (success) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("There was an error")
                }
            })
        }
    }
    
    @IBAction func groupNameChanged(_ sender: Any) {
        if groupNameTxt.text == "" && chosenEmailArray.count >= 1 {
            doneButton.isHidden = true
        } else {
            doneButton.isHidden = false
        }
    }
    
}



extension CreateGroupVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")  as? UserCell else {
            return UserCell()
        }
        
        //cell.emailTxt.text = emailArray[indexPath.row]
        
        if chosenEmailArray.contains(emailArray[indexPath.row]) {
            cell.configureCell(withEmail: emailArray[indexPath.row], isSelected: true)
        } else {
            cell.configureCell(withEmail: emailArray[indexPath.row], isSelected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else {return}

        if chosenEmailArray.count <= 3 {
            if !chosenEmailArray.contains(cell.emailTxt.text!) {
                chosenEmailArray.append(cell.emailTxt.text!)
                groupMembersTxt.text = chosenEmailArray.joined(separator: ", ")
                //cell.configureCell(withEmail: emailArray[indexPath.row], isSelected: true)
                //cell.cellSelected = true
                if groupNameTxt.text != "" {
                    doneButton.isHidden = false
                }
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else {return}
        
        chosenEmailArray = chosenEmailArray.filter({ $0 != cell.emailTxt.text! })
        
        //cell.cellSelected = false
        if chosenEmailArray.count >= 1 {
            groupMembersTxt.text = chosenEmailArray.joined(separator: ", ")
        } else {
            groupMembersTxt.text = "add people to your group"
            doneButton.isHidden = true
        }
    }
    
    
}
