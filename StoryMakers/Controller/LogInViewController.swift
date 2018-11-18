//
//  LogInViewController.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/11/25.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit
import Firebase


class LogInViewController: UIViewController {

    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGesture)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logInButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: login.text!, password: password.text!) { user, error in
            
            if error != nil {
                print(error!.localizedDescription)
                self.showAlert(title: "Message:", message: error!.localizedDescription, actionHandler: nil)
            } else {
                if (Auth.auth().currentUser?.isEmailVerified)! {
                    print("Log in succesful")
                    self.performSegue(withIdentifier: "logInToStoryList", sender: self)
                } else {
                    print("Please verify your e-mail.")
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    self.showAlert(title: "Message: ", message: "Please verify your e-mail to log in.", actionHandler: nil)
                    
                }
            }
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        if login.text != "" {
            Auth.auth().sendPasswordReset(withEmail: login.text!) { (error) in
                if error != nil {
                    self.showAlert(title: "Error", message: error.debugDescription, actionHandler: nil)
                }
            }
        } else {
            showAlert(title: "Warning", message: "Please enter your email.", actionHandler: nil)
        }
    }
    
    @objc func viewTapped() {
        login.endEditing(true)
        password.endEditing(true)
    }
    
}
