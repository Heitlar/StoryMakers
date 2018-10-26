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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logInButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: login.text!, password: password.text!) { user, error in
            
            if error != nil {
                print(error!.localizedDescription)
                self.alert(title: "Message:", message: error!.localizedDescription)
            } else {
                if (user?.isEmailVerified)! {
                    print("Log in succesful")
                    self.performSegue(withIdentifier: "logInToStoryList", sender: self)
                } else {
                    print("Please verify your e-mail.")
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    self.alert(title: "Message: ", message: "Please verify your e-mail to log in.")
                }
            }
        }
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}
