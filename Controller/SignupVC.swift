//
//  SignupVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 11/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import Firebase

class SignupVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTxt: CustomTextField!
    @IBOutlet weak var fullNameTxt: CustomTextField!
    @IBOutlet weak var pwdText: CustomTextField!
    @IBOutlet weak var confirmPwdText: CustomTextField!
    @IBOutlet weak var pwdMatchErrorTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.createGradientLayer(withColours: [UIColor.orange.cgColor, UIColor.black.cgColor], changeLocations: [0.60])
        emailTxt.delegate = self
        fullNameTxt.delegate = self
        pwdText.delegate = self
        confirmPwdText.delegate = self
        pwdMatchErrorTxt.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text! == "" {
            return false
        } else if textField == emailTxt {
            textField.resignFirstResponder()
            fullNameTxt.becomeFirstResponder()
            return true
        } else if textField == fullNameTxt {
            textField.resignFirstResponder()
            pwdText.becomeFirstResponder()
            return true
        } else if textField == pwdText {
            textField.resignFirstResponder()
            confirmPwdText.becomeFirstResponder()
            return true
        } else {
            textField.resignFirstResponder()
            return true
        }
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        pwdMatchErrorTxt.text = ""
        pwdMatchErrorTxt.isHidden = true
        if emailTxt.text == "" || pwdText.text == "" || confirmPwdText.text == "" || fullNameTxt.text == ""{
            pwdMatchErrorTxt.text = "Make sure all fields are complete"
            pwdMatchErrorTxt.isHidden = false
        } else if (pwdText.text!.count < 8) {
            pwdMatchErrorTxt.text = "Make sure that the password is at least 8 characters long"
            pwdMatchErrorTxt.isHidden = false
        } else if (pwdText.text != confirmPwdText.text) {
            pwdMatchErrorTxt.text = "Please re-type password"
            pwdMatchErrorTxt.isHidden = false
        } else {
            AuthService.instance.registerUser(withEmail: emailTxt.text!, andPassword: pwdText.text!, withName: fullNameTxt.text!) { (success, signupError) in
                if success {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
                    self.present(vc, animated: true, completion: nil)
                } else {
                    self.pwdMatchErrorTxt.text = signupError?.localizedDescription
                    self.pwdMatchErrorTxt.isHidden = false
                }
            }
        }
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
