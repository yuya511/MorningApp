//
//  menuMemberTableViewCell.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/02.
//

import UIKit
import Firebase
import FirebaseUI

class menuMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var memberLabel: UILabel!
    

    func setUserData(_ userData: User) {
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userData.uid + ".jpg")
        memberImageView.sd_setImage(with: imageRef)
        
        self.memberLabel.text = "\(userData.username ?? "")"
    }

    func setGroupData(_ groupData: User) {
        self.memberLabel.text = "\(groupData.groupname ?? "")"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        memberImageView.layer.cornerRadius = 15

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
