//
//  AuthService.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 11/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn


class AuthService {
    
    static let instance = AuthService()
    
    func registerUser(withEmail email: String, andPassword pwd: String, withName name: String, userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: pwd) { (user, error) in
            guard let user = user else {
                userCreationComplete(false, error)
                return
            }
            
            let userData = ["provider": user.user.providerID, "email": user.user.email, "fullname": name]
            DataService.instance.createDBUser(uid: user.user.uid, userData: userData as Dictionary<String, Any>)
            userCreationComplete(true, nil)
        }
    }
    
    
    
    func loginUser(withEmail email: String, andPassword pwd: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: pwd) { (user, error) in
            guard user != nil else {
                loginComplete(false, error)
                return
            }
            loginComplete(true, nil)
        }
    }
    
    func FBLogin(withViewController vc: UIViewController, completion: @escaping (_ completion: Bool) -> ()) {
        
        //First, create an instance of the login manager provided by FB consisting of the methods to log in and log out.
        let loginManager = LoginManager()
    
        
        //start login, and request public profile and email
        loginManager.logIn(permissions: ["public_profile", "email"], from: vc) { (result, error) in
            
            //If there is an error, terminate process
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            //Check if the current user has a valid access token to continue login. If not, terminate.
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            
            //get user credentials using the access token
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                //if error, display error and terminate.
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    vc.present(alertController, animated: true, completion: nil)
                    return
                }
                
                
                //Now, the user has been logged in. Now, we need to get the data to upload to the Firebase RTDB.
                //Create dictionary to hold user data
                var userData = [String : String]()
                userData["provider"] = FacebookAuthProviderID
                
                //start request to gain access to user information.
                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) in
                    if error != nil {
                        print("There was an error in processing your request")
                        return
                    }
                    
                    //if retrieval is successful, then cast the data as a dictionary and retrive the relevant data, and add it to UserData.
                    if let data = result as? NSDictionary {
                        userData["fullname"] = data.object(forKey: "name") as? String
                        if let email = data.object(forKey: "email") as? String {
                            userData["email"] = email
                        } else {
                            print("There was an error in retrieving your facebook data, please use other login methods")
                            return
                        }
                        
                        //create user with user data in Firebase RTDB.
                        DataService.instance.createDBUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData)
                        completion(true)
                    }
                    
                    
                })
            }

        }
    }
    
}
