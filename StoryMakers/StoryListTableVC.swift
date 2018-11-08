//
//  StoryListTableVC.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/12/01.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit
import Firebase


class StoryListTableVC: UITableViewController, CellDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var storyArray = [Story]()
    var searchStoryArray = [Story]()
    let reference = Database.database().reference()
    let currentUser = Auth.auth().currentUser
    var storyMakersRow = 0
    var array = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        searchBar.delegate = self
        let backgroundImage = UIImage(named: "Books")
        let imageView = UIImageView(image: backgroundImage)
        tableView.backgroundView = imageView
        
        getStoryListItems()
        tableView.register(UINib(nibName: "StoryListCell", bundle: nil), forCellReuseIdentifier: "StoryListCell")
        tableView.separatorStyle = .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchStoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryListCell", for: indexPath) as! StoryListCell
        
        cell.delegate = self
        cell.storyName.layer.shadowRadius = 2.0
        cell.storyName.layer.shadowColor = UIColor.white.cgColor
        cell.storyName.layer.shadowOpacity = 80.0
        cell.storyName.text = searchStoryArray[indexPath.row].name
        cell.button.addTarget(self, action: #selector(segueAction), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        storyChosenManager(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            reference.child("StoryList").child(storyArray[indexPath.row].name).observeSingleEvent(of: .childAdded, with: { snapshot in
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
                    self.showAlert(title: "Warning", message: "Can't delete story made by another user.", actionHandler: nil)
                    print("\(currentUser) is not the creator of this story.")
                }
            })
        }
    }
    
    //MARK: My functions
    
    func getStoryListItems() {
        reference.child("StoryList").observe(.childAdded) { snapshot in
            let story = Story()
            story.name = snapshot.key
            self.storyArray.append(story)
            self.searchStoryArray = self.storyArray
            self.tableView.reloadData()
        }
    }
    
    func storyChosenManager(indexPath: IndexPath) {
        
        reference.child("StoryList").child(searchStoryArray[indexPath.row].name).observeSingleEvent(of: .childAdded) { snapshot in
            let snapshotValue = snapshot.value as! [String : String]
            
            if snapshotValue["StoryCreator"]! == self.currentUser!.email! {
                self.performSegue(withIdentifier: "StoryChosen", sender: self.tableView.cellForRow(at: indexPath))
            } else if snapshotValue["StoryPassword"] == nil || snapshotValue["StoryPassword"]! == "" {
                self.performSegue(withIdentifier: "StoryChosen", sender: self.tableView.cellForRow(at: indexPath))
            } else {
                
                let alert = UIAlertController(title: "Warning", message: "Enter password:", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { alertAction in
                    let textField = alert.textFields!.first!

                    if textField.text! != snapshotValue["StoryPassword"]! {
                        self.showAlert(title: "Error", message: "Wrong password", actionHandler: nil)
                    } else {
                        self.performSegue(withIdentifier: "StoryChosen", sender: self.tableView.cellForRow(at: indexPath))
                    }
                }

                alert.addTextField { textField in
                    textField.placeholder = "password"
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
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
            navigationController?.popToRootViewController(animated: true)
        } catch {
            self.showAlert(title: "Error", message: "You should log in first", actionHandler: nil)
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
                    self.performSegue(withIdentifier: "StoryListToStory", sender: self)
                }
            }
        }
        action.isEnabled = false
        alert.addTextField { (storyName) in
            storyName.autocapitalizationType = UITextAutocapitalizationType.sentences
            storyName.placeholder = "Enter your story name here."
            storyName.addTarget(self, action: #selector(self.enableAlertButton(text:)), for: .editingChanged)
        }
        alert.addTextField { (passwordText) in
            passwordText.isSecureTextEntry = true
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
                destinationVC.storyNameDelegate = searchStoryArray[indexPath.row].name
            }
            clearSearch()
        } else if segue.identifier == "StoryListToStory" {
            let currentName = searchStoryArray[storyArray.count - 1].name
            
            let destinationVC = segue.destination as! StoryViewController
            destinationVC.storyNameDelegate = currentName
        }
            
        else if segue.identifier == "StoryMakers" {
            let destinationVC = segue.destination as! StoryMakersTableVC
            destinationVC.storyNameDelegate = searchStoryArray[storyMakersRow].name
            
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
    
    func buttonTapped(cell: StoryListCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        storyMakersRow = indexPath!.row
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStoryArray = searchText.isEmpty ? storyArray : storyArray.filter { (item: Story) -> Bool in
            return item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        clearSearch()
    }
    
    func clearSearch() {
        searchBar.text = ""
        searchStoryArray = storyArray
        tableView.reloadData()
        searchBar.resignFirstResponder()
        
    }
}



