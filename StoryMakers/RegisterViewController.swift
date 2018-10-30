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
//        if createNickname() {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { user, error in
                
                if error != nil {
                    self.alert(title: "Error", message: error!.localizedDescription, handler: nil)
                    print("<<Error:", error!.localizedDescription, ">>")
                } else {
                    if (Auth.auth().currentUser?.isEmailVerified)! {
                        print("Log in succesful")
                        self.performSegue(withIdentifier: "RegisterToStoryList", sender: self)
                    } else {
                        self.createNickname()
                        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                        let message = "A letter has been sent to your e-mail. Please verify your e-mail to log in."
                        self.alert(title: "Message:", message: message, handler: { action in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                }
            }
//        } else {
//            let message = "Nickname taken. Please choose another."
//            alert(title: "Error", message: message, handler: nil)
//        }

    }
    
    func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func createNickname() {
//        var bool = false
        let database = reference.child("Nicknames")
        let dictionary = ["Nickname": nickname.text!, "Email": email.text!]
//        DispatchQueue.main.async {
        
//            database.observe(.childAdded) { (snapshot) in
//                let snapshotValue = snapshot.value as! [String : String]
//                var nickNamesArray = [String]()
//                DispatchQueue.main.async {
//                    nickNamesArray.append(snapshotValue["Nickname"]!)
//                }
//                print(nickNamesArray)
//                if nickNamesArray.contains(self.nickname.text!) {
//                    print("Pick another nickname")
//                    bool = false
//                } else {
                    database.childByAutoId().setValue(dictionary)
//                    bool = true
//                }
//            }
        var arr = [String]()
        database.observe(.childAdded) { (snapshot) in
            
            arr.append(snapshot.key)
            
        }
        print(arr)
        
        }
//        return bool
//    }

}
