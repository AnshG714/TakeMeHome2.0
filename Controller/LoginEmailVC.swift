//
//  LoginEmailVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 10/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoginEmailVC: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var usernameTxt: CustomTextField!
    @IBOutlet weak var pwdTxt: CustomTextField!
    @IBOutlet weak var errorTxt: UILabel!
    @IBOutlet weak var loginBtn: CustomButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //createGradientLayer()
        self.view.createGradientLayer(withColours: [UIColor.orange.cgColor, UIColor.black.cgColor], changeLocations: [0.60])
        usernameTxt.delegate = self
        pwdTxt.delegate = self
        errorTxt.isHidden = true
        
        let activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: NVActivityIndicatorType.ballPulse, color: UIColor.black, padding: 20)
        self.view.addSubview(activityIndicatorView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text! == "" {
            return false
        } else if textField == usernameTxt {
            textField.resignFirstResponder()
            pwdTxt.becomeFirstResponder()
            return true
        } else {
            pwdTxt.resignFirstResponder()
            return true
        }
    }
    
    
    @IBAction func textFieldsChanged(_ sender: Any) {
        if usernameTxt.text != "" && pwdTxt.text != "" {
            loginBtn.isEnabled = true
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let size = CGSize(width: 30, height: 30)
        startAnimating(size, message: "Logging in", type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
        if usernameTxt.text != "" && pwdTxt.text != "" && usernameTxt.text != nil && pwdTxt.text != nil {
            loginBtn.isEnabled = false
            //self.loginEmailVC.startAnimating()
            AuthService.instance.loginUser(withEmail: usernameTxt.text!, andPassword: pwdTxt.text!) { (success, loginError) in
                if (success) {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
                    self.present(vc, animated: true, completion: nil)
                    //self.loginEmailVC.stopAnimating()
                } else {
                    //self.loginEmailVC.stopAnimating()
                    self.errorTxt.text = "Invalid entry for email or password. Please try again."
                    self.errorTxt.isHidden = false
                }
                self.stopAnimating(nil)
            }
            
            loginBtn.isEnabled = true
        }
    }
}

