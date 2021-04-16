//
//  User.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/22.
//

import Foundation
import Firebase

class User {
    
    let uid: String
    
    let email: String?
    let username: String?
    let groupId: String?
    let profileText: String?
    let createdAt: Data?
    let doSupport: Int?
    let BedoneSupport: Int?
    let nowGroup: String?
    
    
//    init(document: QueryDocumentSnapshot) {
        
    init(document: DocumentSnapshot) {

        self.uid = document.documentID
        
        let userDic = document.data()
        
        self.email = userDic?["email"] as? String ?? ""
        self.username = userDic?["username"] as? String ?? ""
        self.groupId = userDic?["groupId"] as? String ?? ""
        self.profileText = userDic?["profileText"] as? String ?? ""
        let timestamp = userDic?["createdAt"] as? Timestamp
        self.createdAt = timestamp?.dateValue() as? Data
        self.doSupport = userDic?["doSupport"] as? Int ?? 0
        self.BedoneSupport = userDic?["BedoneSupport"] as? Int ?? 0
        self.nowGroup = userDic?["nowGroup"] as? String ?? ""
        
    }
    
}
