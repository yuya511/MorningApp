//
//  ContainerController.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/01.
//

import UIKit
import Firebase


class ContainerController: UIViewController {

    @IBOutlet weak var editButton: UIButton!
    @IBAction func MorningButton(_ sender: Any) {
        print("DEBUG_PRINT* MorningButton")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { (document, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dic = document?.data() else { return }
            guard let username = dic["username"] else { return }
            
            let chatroomRef = Firestore.firestore().collection(Const.ChatRooms).document()
            
            let chatroomDic = [
                "name": username,
                "text": "",
                "stamp": true,
                "date": Timestamp(),
                "uid": uid,
            ] as [String : Any]
            chatroomRef.setData(chatroomDic)
            print("tappedMorningButtonの情報が保存されました")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editButton.layer.cornerRadius = 50
    }
    

    

}
