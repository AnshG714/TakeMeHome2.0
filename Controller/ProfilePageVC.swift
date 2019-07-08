//
//  ProfilePageVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 04/07/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfilePageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func SignOutButtonTapped(_ sender: Any) {
    
        AccessToken.current = nil
        Profile.current = nil
        let loginManager = LoginManager()
        loginManager.logOut()
        GIDSignIn.sharedInstance()?.signOut()
        try! Auth.auth().signOut()
        
        
        
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginMainVC") as! LoginMainVC
            self.present(vc, animated: true, completion: nil)
        }
    }
}
