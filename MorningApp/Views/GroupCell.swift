//
//  GroupCell.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/17.
//

import UIKit
import Firebase
import FirebaseUI

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var membarCountLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var LockButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupImageView.layer.cornerRadius = 10
    }
    
    
    func setGroupData(_ groupData: Group) {
        let groupId = groupData.groupId
        let imageRef = Storage.storage().reference().child(Const.GroupImage).child(groupId + ".jpg")
        groupImageView.sd_setImage(with: imageRef)
        
        groupNameLabel.text = groupData.groupName
        membarCountLabel.text = "(\(groupData.membar.count))"
        if groupData.groupProfileText != "" {
            descriptionLabel.text = groupData.groupProfileText
        }
        if groupData.password == "" {
            LockButton.isHidden = true
        }
    }

   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
