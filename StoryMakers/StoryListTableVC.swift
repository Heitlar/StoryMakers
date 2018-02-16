//
//  StoryListTableVC.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/12/01.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit
import Firebase


class StoryListTableVC: UITableViewController {

    var storyArray = [Story]()
    let reference = Database.database().reference()
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backGroundImage = UIImage(named: "Books")
        let imageView = UIImageView(image: backGroundImage)
        tableView.backgroundView = imageView
        
        
        reference.child("StoryList").observe(.childAdded) { (snapshot) in
            let story = Story()
            story.name = snapshot.key
            self.storyArray.append(story)
            self.tableView.reloadData()
        }
    
        tableView.register(UINib(nibName: "StoryListCell", bundle: nil), forCellReuseIdentifier: "StoryListCell")

        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryListCell", for: indexPath) as! StoryListCell
        
//        let storyNameLabel = cell.viewWithTag(100) as! UILabel
//        let storyNameLabel = cell.storyName!
//        let storyCreatorLabel = cell.viewWithTag(101) as! UILabel
        
        cell.storyName.layer.shadowRadius = 2.0
        cell.storyName.layer.shadowColor = UIColor.white.cgColor
        cell.storyName.layer.shadowOpacity = 80.0
        
//        storyNameLabel.text = storyNamesArray[indexPath.row]
//        storyCreatorLabel.text = storyCreatorArray[indexPath.row]
        cell.storyName.text = storyArray[indexPath.row].name
//        storyNameLabel.text = storyArray[indexPath.row].name
//        storyCreatorLabel.text = storyArray[indexPath.row].maker
        cell.button.addTarget(self, action: #selector(segueAction), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let name = storyArray[indexPath.row].name
        
        reference.child("StoryList").child(name).observeSingleEvent(of: .childAdded) { snapshot in
            let snapshotValue = snapshot.value as! [String : String]
            
            
            if snapshotValue["StoryCreator"]! == self.currentUser!.email! {
                self.performSegue(withIdentifier: "StoryChosen", sender: tableView.cellForRow(at: indexPath))
            } else if snapshotValue["StoryPassword"] == nil || snapshotValue["StoryPassword"]! == "" {
                self.performSegue(withIdentifier: "StoryChosen", sender: tableView.cellForRow(at: indexPath))

            } else {
                let alert = UIAlertController(title: "Warning", message: "Enter password:", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { alertAction in
                    let textField = alert.textFields!.first!
                    
                     if textField.text! != snapshotValue["StoryPassword"]! {
                        let alert = UIAlertController(title: "Error", message: "Wrong password", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.performSegue(withIdentifier: "StoryChosen", sender: tableView.cellForRow(at: indexPath))
                    }
                }
                alert.addTextField { textField in
                    textField.placeholder = "password"
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            reference.child("StoryList").child(storyArray[indexPath.row].name).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                let snapshotValue = snapshot.value as! Dictionary<String,String>
                guard let storyCreator = snapshotValue["StoryCreator"] else {
                    print("Where is no creators in this story.")
                    return
                }
                guard let currentUser = self.currentUser!.email else {
                    print("User not logged in.")
                    return
                }
                if storyCreator == currentUser {
                    self.deleteFromDBAndTableView(indexPath)
                } else {
                    let alert = UIAlertController(title: "Warning", message: "Can't delete story made by another user.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    print("\(currentUser) is not the creator of this story.")
                }
            })
        }  //else if editingStyle == .insert {
//            Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}
    }
    
    //MARK: My functions
    
    func deleteFromDBAndTableView(_ indexPath: IndexPath) {
        
        reference.child("StoryList").child(storyArray[indexPath.row].name).removeValue(completionBlock: { (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print(reference.description(), "removed.")
            }
        })
        storyArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            print("Log out successful.")
            navigationController?.popToRootViewController(animated: true)

        } catch {
            print("Error, problems logging out.")
        }
    }
    
    
    @IBAction func addNewStory(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Enter your story name:", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let action = UIAlertAction(title: "Accept", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let passwordTextField = alert.textFields![1] as UITextField
            
            let database = self.reference.child("StoryList").child(textField.text!)
            let storyNameDictionary = ["Sender": Auth.auth().currentUser?.email!, "StoryName": textField.text!, "StoryText": "", "StoryCreator": self.currentUser?.email!, "StoryPassword": passwordTextField.text!]
            database.childByAutoId().setValue(storyNameDictionary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    print("Story title saved successfully!")
                    self.performSegue(withIdentifier: "StoryListToStory", sender: self)
                }
            }
        }
        action.isEnabled = false
        alert.addTextField { (textField) in
            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
            textField.placeholder = "Enter your story name here."
            textField.addTarget(self, action: #selector(self.enableAlertButton(text:)), for: .editingChanged)
        }
        alert.addTextField { (passwordText) in
            passwordText.placeholder = "Enter password"
        }
        
        alert.addAction(cancelAction)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StoryChosen" {
            
            let destinationVC = segue.destination as! StoryViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                destinationVC.storyNameDelegate = storyArray[indexPath.row].name
            }
        } else if segue.identifier == "StoryListToStory" {
            let currentName = storyArray[storyArray.count - 1].name
            
            let destinationVC = segue.destination as! StoryViewController
            destinationVC.storyNameDelegate = currentName
        }
            //TODO: ADD CHANGES HERE!
        else if segue.identifier == "StoryMakers" {
//            let destinationVC = segue.destination as! StoryMakersTableVC
            print("Story Makers Segue.")
        }
    }

    @objc func enableAlertButton(text: UITextField) {
        let alertController = self.presentedViewController as! UIAlertController
        let textField = alertController.textFields![0]
        let addAction = alertController.actions[1]
        addAction.isEnabled = textField.text?.isEmpty == false
    }
    
    @objc func segueAction() {
        performSegue(withIdentifier: "StoryMakers", sender: self)
        
    }
    

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    

    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITableView {
    func indexPathForView(view: AnyObject) -> IndexPath? {
        let location = view.convert(CGPoint.zero, to: self)
        return self.indexPathForRow(at: location)
    }
}

