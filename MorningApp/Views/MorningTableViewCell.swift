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
//            userTextView.isHidden = true
//            userDateLabel.isHidden = true
//            usernameLabel.isHidden = true
//            userImgeView.isHidden = true
//
//            myTextView.isHidden = false
//            myDateLabel.isHidden = false
//
//            self.myTextView.text = chatrooms.text
//            //テキストサイズに揃える
//            guard let text = chatrooms.text else { return }
//            let width = estimateFrameForTextView(text: text).width + 20
//            myTextWidthConstraint.constant = width
//            myTextView.text = text
//
//            self.myDateLabel.text = ""
//            if let date = chatrooms.date {
//                let formatter = DateFormatter()
//                formatter.dateStyle = .none
//                formatter.timeStyle = .short
//                formatter.locale = Locale(identifier: "ja_JP")
//                let dateString = formatter.string(from: date)
//                self.myDateLabel.text = dateString
            }
            
//        } else {
//            userTextView.isHidden = false
//            userDateLabel.isHidden = false
//            usernameLabel.isHidden = false
//            userImgeView.isHidden = false
//
//            myTextView.isHidden = true
//            myDateLabel.isHidden = true
//        }
        
        
    }

}
