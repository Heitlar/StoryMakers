//
//  RegisterViewController.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/11/25.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nickname: UITextField!
    
    let reference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { user, error in
            
            if error != nil {
                self.showAlert(title: "Error", message: error!.localizedDescription, actionHandler: nil, textFieldHandler: nil)
                print("<<Error:", error!.localizedDescription, ">>")
            } else {
                if (Auth.auth().currentUser?.isEmailVerified)! {
                    print("Log in succesful")
                    self.performSegue(withIdentifier: "RegisterToStoryList", sender: self)
                } else {
                    self.createNickname()
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    let message = "A letter has been sent to your e-mail. Please verify your e-mail to log in."
                    self.showAlert(title: "Message:", message: message, actionHandler: { action in
                        self.navigationController?.popToRootViewController(animated: true)
                    }, textFieldHandler: nil)
                }
            }
        }
    }
    
    func createNickname() {
        let database = reference.child("Nicknames")
        let dictionary = ["Nickname": nickname.text!, "Email": email.text!]
        database.childByAutoId().setValue(dictionary)
        
        var arr = [String]()
        database.observe(.childAdded) { (snapshot) in
            
            arr.append(snapshot.key)
        }
    }
    
}
