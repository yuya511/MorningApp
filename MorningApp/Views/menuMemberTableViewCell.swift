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
    @IBOutlet weak var memberCount: UILabel!
    
    @IBOutlet weak var menuCheckImage: UIImageView!
    func setUserData(_ userData: User) {
        memberImageView.layer.cornerRadius = 22.5
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userData.uid + ".jpg")
        memberImageView.sd_setImage(with: imageRef)
        self.memberCount.isHidden = true
        self.memberCount.isEnabled = false
        self.menuCheckImage.isHidden = true
        self.memberLabel.text = "\(userData.username ?? "")"
    }

    func setGroupData(_ groupData: Group) {
        memberImageView.layer.cornerRadius = 10
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == groupData.groupId {
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            memberImageView.sd_setImage(with: imageRef)
            
            self.memberCount.isHidden = true
            self.memberCount.isEnabled = false
            self.menuCheckImage.isHidden = false
            self.memberLabel.text = "\(groupData.groupName ?? "")"
        } else {
            let imageRef = Storage.storage().reference().child(Const.GroupImage).child(groupData.groupId + ".jpg")
            memberImageView.sd_setImage(with: imageRef)
            
            self.memberCount.isHidden = false
            self.memberCount.isEnabled = true
            self.menuCheckImage.isHidden = false
            self.memberCount.text = "(\(groupData.membar.count))"
            self.memberLabel.text = "\(groupData.groupName ?? "")"
        }
        
        let userRef = Firestore.firestore().collection(Const.User).document(uid)
        userRef.getDocument() { (document,err) in
            if let err = err {
                print("***err",err)
                return
            }
            let userData = document?.data()
            
            if groupData.groupId == userData?["nowGroup"] as! String {
                self.menuCheckImage.isHidden = false
            } else {
                self.menuCheckImage.isHidden = true
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
