//
//  StoryMakerModel.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/12/19.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit

class User {
    var name = ""
    var email = ""
}

class Story {
    var sender = ""
    var maker = ""
    var name = ""
    var text = ""
}

class Alert {
  
    public static func create(viewController: UIViewController, title: String, message: String, buttonTitle: String, closure: ((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: closure)
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
}



