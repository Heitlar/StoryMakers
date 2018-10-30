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
    var dict = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().reference().child("StoryList").child(storyNameDelegate).observe(.childAdded) { snapshot in
            let snapshotValue = snapshot.value as! [String : String]
            self.storyMakersSections[1].append(snapshotValue["Sender"]!)
            let uniqueMakersArray = Array(Set(self.storyMakersSections[1]))
            if let storyCreator = snapshotValue["StoryCreator"] {
                self.storyMakersSections[0].append(storyCreator)
            }
            self.storyMakersSections[1] = uniqueMakersArray
//            print(self.storyMakersSections)
            self.tableView.reloadData()
        }
        
        Database.database().reference().child("Nicknames").observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [String : String]
//            if self.storyMakersSections[0].contains(snapshotValue["Email"]!) {
//                self.nickNames[0].append(snapshotValue["Nickname"]!)
//            } else if self.storyMakersSections[1].contains(snapshotValue["Email"]!) {
//                self.nickNames[1].append(snapshotValue["Nickname"]!)
//            }
            
            let key = snapshotValue["Email"]!
            let value = snapshotValue["Nickname"]!
            self.dict[key] = value
            self.tableView.reloadData()
//            print(self.dict)
        }
        
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
        if let nickname = dict[email] {
            cell.textLabel?.text = "\(nickname)(\(email))"
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
