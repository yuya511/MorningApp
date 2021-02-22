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
    var usertext: String? {
        didSet {
            guard let text = usertext else { return }
            let width = estimateFrameForTextView(text: text).width + 20
            
            userTextWidthConstraint.constant = width
            userTextView.text = text
        }
    }
    

    @IBOutlet weak var userImgeView: UIImageView!
    @IBOutlet weak var userTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userTextWidthConstraint: NSLayoutConstraint!
    @IBOutlet var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        userImgeView.layer.cornerRadius = 25
        userTextView.layer.cornerRadius = 10
        usernameLabel.textAlignment = NSTextAlignment.center
        setUserData()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUserData() {
       
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG_PRINT: uidがありません。")
            return
        }
        
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(uid + ".jpg")
        userImgeView.sd_setImage(with: imageRef)
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dic = document?.data() else { return }
            print("DEBUG_PRINT: \(dic)")
            let username =  dic["username"]
            self.usernameLabel.text = username as? String
        }
        
        
        
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }

}
