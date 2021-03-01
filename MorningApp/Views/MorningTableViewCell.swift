//
//  MorningTableViewCell.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/25.
//

import UIKit
import Firebase
import FirebaseUI

class MorningTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var morningImageView: UIImageView!
    @IBOutlet weak var morningNameLabel: UILabel!
    @IBOutlet weak var stampImageView: UIImageView!
    @IBOutlet weak var morningDateLabel: UILabel!
    
    @IBOutlet weak var myMorningImageView: UIImageView!
    @IBOutlet weak var myMoriningDateLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        morningImageView.layer.cornerRadius = 17.5

    }
    
    func setUserData(_ chatrooms: Chatroom) {
        //画像の表示
        if let uid = chatrooms.uid {
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            morningImageView.sd_setImage(with: imageRef)
        }
        
        //ユーザーの名前
        self.morningNameLabel.text = chatrooms.name
        
        //日時の表示
        self.morningDateLabel.text = ""
        if let date = chatrooms.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ja_JP")
            let dateString = formatter.string(from: date)
            self.morningDateLabel.text = dateString
        }

     
        //メッセージの切り分け
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == chatrooms.uid {
            morningImageView.isHidden = true
            morningNameLabel.isHidden = true
            morningDateLabel.isHidden = true
            stampImageView.isHidden = true
            
            myMorningImageView.isHidden = false
            myMoriningDateLabel.isHidden = false
            
           
            self.myMoriningDateLabel.text = ""
            if let date = chatrooms.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                formatter.locale = Locale(identifier: "ja_JP")
                let dateString = formatter.string(from: date)
                self.myMoriningDateLabel.text = dateString
            }
            
        } else {
            stampImageView.isHidden = false
            morningDateLabel.isHidden = false
            morningNameLabel.isHidden = false
            morningImageView.isHidden = false
            
            myMoriningDateLabel.isHidden = true
            myMorningImageView.isHidden = true
        }
    }
}
