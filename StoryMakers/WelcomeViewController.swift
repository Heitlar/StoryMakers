//
//  ViewController.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/11/25.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            if (Auth.auth().currentUser?.isEmailVerified)! {
            self.performSegue(withIdentifier: "WelcomeToStoryList", sender: nil)
            } else {
                print("Please verify your e-mail to login.")
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

