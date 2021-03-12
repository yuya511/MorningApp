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
    @IBOutlet weak var morningDateLabel: UILabel!
    
    @IBOutlet weak var mokuLabel: UILabel!
    @IBOutlet weak var targetTextView: UITextView!
    
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var fireCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .rgb(red: 152, green: 187, blue: 219)
        layer.borderColor = UIColor.rgb(red: 220, green: 230, blue: 245).cgColor
        layer.borderWidth = 2.0
        layer.cornerRadius = 10
        
        mokuLabel.layer.cornerRadius = 7.5
        mokuLabel.clipsToBounds = true
        targetTextView.layer.cornerRadius = 5
        targetTextView.backgroundColor = .rgb(red: 250, green: 250, blue: 250)
        targetTextView.layer.borderColor = UIColor.orange.cgColor
        targetTextView.layer.borderWidth = 1.5
        self.targetTextView.text = ""
        self.fireCountLabel.text = "0"
        
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
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ja_JP")
            let dateString = formatter.string(from: date)
            self.morningDateLabel.text = dateString
        }
        
        //目標の部分のデータ
        self.targetTextView.text = chatrooms.text
        
        self.fireCountLabel.text = String(chatrooms.supports.count)
        
        if chatrooms.isSupport {
            fireButton.setImage(UIImage(named: "火"), for: .normal)
        } else {
            fireButton.setImage(UIImage(named: "影火"), for: .normal)
        }
     
    }
}
