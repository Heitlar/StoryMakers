//
//  StoryViewController.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/11/25.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit
import Firebase

class StoryViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    
    var storyNameDelegate = ""
    var reference = Database.database().reference()
    
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyText: UITextView!
    @IBOutlet weak var addTextToStory: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storyText.delegate = self
        addTextToStory.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
        storyText.addGestureRecognizer(tapGesture)
        
        sendButton.isEnabled = false
        storyTitle.text = storyNameDelegate
        addTextToStory.addTarget(self, action: #selector(textFieldContains(textField:)), for: .editingChanged)
        retrieveSentence()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:   BUTTONS!
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error, problems logging out.")
        }
    }
    
    
    @IBAction func addStoryButton(_ sender: Any) {
        appendTextToStory()
    }
    
    
    @IBAction func keyboardAddStory(_ sender: Any) {
        appendTextToStory()
        print("Keyboard 'send' tapped")
    }
    
    func retrieveSentence() {
        let database = reference.child("StoryList").child(storyTitle.text!)
        database.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! [String : String]
            
            var storyText = snapshotValue["StoryText"]!
            let storyName = snapshotValue["StoryName"]!
            let sender = snapshotValue["Sender"]!
            if storyText != "" {
                self.reference.child("Nicknames").observe(.childAdded) { (snapshot) in
                    let snapshotValue = snapshot.value as! [String : String]
                    if snapshotValue["Email"]! == sender {
                        storyText = "(\(snapshotValue["Nickname"]!)): \(storyText) "
                        
                        if storyName == self.storyTitle.text {
                            self.storyText.text! += storyText
                        }
                    }
                }
            }     
        }
    }
    
    @objc func textViewTapped() {
        addTextToStory.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.27) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.27) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    func appendTextToStory() {
        if addTextToStory.text! != "" {
            addTextToStory.endEditing(true)
            addTextToStory.isEnabled = false
            sendButton.isEnabled = false
            
            let database = reference.child("StoryList").child(storyTitle.text!)
            let storyDictionary = ["Sender": Auth.auth().currentUser?.email, "StoryName": storyTitle.text!, "StoryText": addTextToStory.text!]
            database.childByAutoId().setValue(storyDictionary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    print("Sentence saved successfully!")
                    self.addTextToStory.text! = ""
                    self.addTextToStory.isEnabled = true
                    self.sendButton.isEnabled = true
                }
            }
        }
    }
    
    @objc func textFieldContains(textField: UITextField) {
        if textField.text != "" {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
}
