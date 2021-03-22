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
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userData.uid + ".jpg")
        memberImageView.sd_setImage(with: imageRef)
        self.memberCount.isHidden = true
        self.memberCount.isEnabled = false
        self.menuCheckImage.isHidden = true
        self.memberLabel.text = "\(userData.username ?? "")"
    }

    func setGroupData(_ groupData: Group) {
        memberImageView.layer.cornerRadius = 10
        let imageRef = Storage.storage().reference().child(Const.GroupImage).child(groupData.groupId + ".jpg")
        memberImageView.sd_setImage(with: imageRef)
        self.memberCount.text = "(\(groupData.membar.count))"
        self.memberLabel.text = "\(groupData.groupName ?? "")"
        
        guard let uid = Auth.auth().currentUser?.uid else { return}
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
        memberImageView.layer.cornerRadius = 22.5

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
