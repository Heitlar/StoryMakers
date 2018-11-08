//
//  Extensions.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2018/11/08.
//  Copyright © 2018 Sergey Larkin. All rights reserved.
//

import UIKit


extension UITableView {
    func indexPathForView(view: AnyObject) -> IndexPath? {
        let location = view.convert(CGPoint.zero, to: self)
        return self.indexPathForRow(at: location)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, actionHandler: ((UIAlertAction) -> Void)?, textFieldHandler: ((UITextField) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: actionHandler)
        alertController.addAction(action)
        if textFieldHandler != nil {
            alertController.addTextField(configurationHandler: textFieldHandler)
        }
        present(alertController, animated: true, completion: nil)
        
    }
}

