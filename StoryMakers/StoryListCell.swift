//
//  StoryListCell.swift
//  StoryMakers
//
//  Created by Sergey Larkin on 2017/12/22.
//  Copyright © 2017 Sergey Larkin. All rights reserved.
//

import UIKit

class StoryListCell: UITableViewCell {

 
    @IBOutlet weak var storyName: UILabel!
    
    @IBOutlet weak var cellBackgroundImage: UIImageView!
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func storyMakersButton(_ sender: UIButton) {
        print("Story Makers Button.")        
    }
    
    
    
}
