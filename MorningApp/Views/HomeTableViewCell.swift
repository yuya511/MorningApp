//
//  HomeTableViewCell.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/19.
//

import UIKit
import FirebaseUI
import Firebase

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var userImgeView: UIImageView!
    @IBOutlet weak var userTextView: UITextView!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var userDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var userTextWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myTextWidthConstraint: NSLayoutConstraint!
    @IBOutlet var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultXibs()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setDefaultXibs() {
        backgroundColor = .clear
        userImgeView.layer.cornerRadius = 17.5
        userTextView.layer.cornerRadius = 10
        myTextView.layer.cornerRadius = 10
        usernameLabel.textAlignment = NSTextAlignment.center
    }
 
    
    func setUserData(_ chatrooms: Chatroom) {
        //画像の表示
        if let uid = chatrooms.uid {
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
            userImgeView.sd_setImage(with: imageRef)
        }
        //ユーザーの名前
        self.usernameLabel.text = chatrooms.name
        //メッセージの表示
        self.userTextView.text = chatrooms.text
        //日時の表示
        self.userDateLabel.text = ""
        if let date = chatrooms.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d H:m"
            formatter.locale = Locale(identifier: "ja_JP")
            let dateString = formatter.string(from: date)
            self.userDateLabel.text = dateString
        }
        //テキストサイズに揃える
        guard let text = chatrooms.text else { return }
        let width = estimateFrameForTextView(text: text).width + 20
        userTextWidthConstraint.constant = width
        userTextView.text = text
        //メッセージの切り分け
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == chatrooms.uid {
            userTextView.isHidden = true
            userDateLabel.isHidden = true
            usernameLabel.isHidden = true
            userImgeView.isHidden = true
            
            myTextView.isHidden = false
            myDateLabel.isHidden = false
            
            self.myTextView.text = chatrooms.text
            //テキストサイズに揃える
            guard let text = chatrooms.text else { return }
            let width = estimateFrameForTextView(text: text).width + 20
            myTextWidthConstraint.constant = width
            myTextView.text = text
            
            self.myDateLabel.text = ""
            if let date = chatrooms.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d H:m"
                formatter.locale = Locale(identifier: "ja_JP")
                let dateString = formatter.string(from: date)
                self.myDateLabel.text = dateString
            }
        } else {
            userTextView.isHidden = false
            userDateLabel.isHidden = false
            usernameLabel.isHidden = false
            userImgeView.isHidden = false
            myTextView.isHidden = true
            myDateLabel.isHidden = true
        }
        
        
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }

}
