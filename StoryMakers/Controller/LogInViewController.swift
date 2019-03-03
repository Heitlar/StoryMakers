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
        
        let alertController = UIAlertController(title: "Enter your email address", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertAction = UIAlertAction(title: "Submit", style: .default) { (alert) in
            let textField = alertController.textFields![0]
            if textField.text != "" {
                Auth.auth().sendPasswordReset(withEmail: textField.text!) { (error) in
                    if error != nil {
                        self.showAlert(title: "Error", message: (error?.localizedDescription)!, actionHandler: nil)
                    } else {
                        self.showAlert(title: "A message has been sent to your email address", message: "", actionHandler: nil)
                    }
                }
            } else {
                self.showAlert(title: "Warning", message: "Please enter your email.", actionHandler: nil)
            }

        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email address"
            textField.keyboardType = UIKeyboardType.emailAddress
        }
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(displayP3Red: 175/255, green: 255/255, blue: 255/255, alpha: 1)
        alertController.view.tintColor = UIColor.black
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    @objc func viewTapped() {
        login.endEditing(true)
        password.endEditing(true)
    }
    
}
