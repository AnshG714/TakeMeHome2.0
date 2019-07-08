//
//  LoginMainVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 11/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

class LoginMainVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.createGradientLayer(withColours: [UIColor.orange.cgColor, UIColor.black.cgColor], changeLocations: [0.60])
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindFromLoginMainVC(mySegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func loginWithFacebookPressed(_ sender: Any) {
        AuthService.instance.FBLogin(withViewController: self) { (success) in
            if success {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginWithGooglePressed(_ sender: Any) {
        
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            print("An error occured during Google Authentication")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            //user signed in
            var userData = [String: String]()
            userData["provider"] = "google.com"
            userData["fullname"] = user!.user.displayName
            userData["email"] = user?.user.email
            
            DataService.instance.createDBUser(uid: Auth.auth().currentUser!.uid, userData: userData)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
            self.present(vc, animated: true, completion: nil)
            
        }
    } 
    
}
