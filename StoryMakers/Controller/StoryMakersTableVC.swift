//
//  StoryMakersTableVC.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/12/21.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit
import Firebase

class StoryMakersTableVC: UITableViewController {

    let sectionArray = ["Story Name Maker:", "Story Makers:"]
    var storyNameDelegate = ""
    var storyMakersSections = [[String](), [String]()]
    var usersInfo = [String: String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStoryMakerEmail()
        getNicknames()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyMakersSections[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryMakerCell", for: indexPath)
        let email = storyMakersSections[indexPath.section][indexPath.row]
        if let nickname = usersInfo[email] {
            cell.textLabel?.text = "\(nickname)(\(email))"
        }
        return cell
    }
    
   // MARK: My functions
    
    func getStoryMakerEmail() {
        Database.database().reference().child("StoryList").child(storyNameDelegate).observe(.childAdded) { snapshot in
            let snapshotValue = snapshot.value as! [String : String]
            self.storyMakersSections[1].append(snapshotValue["Sender"]!)
            let uniqueMakersArray = Array(Set(self.storyMakersSections[1]))
            if let storyCreator = snapshotValue["StoryCreator"] {
                self.storyMakersSections[0].append(storyCreator)
            }
            self.storyMakersSections[1] = uniqueMakersArray
            self.tableView.reloadData()
        }
    }
    
    func getNicknames() {
        Database.database().reference().child("Nicknames").observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [String : String]
            let key = snapshotValue["Email"]!
            let value = snapshotValue["Nickname"]!
            self.usersInfo[key] = value
            self.tableView.reloadData()
        }
    }

}
