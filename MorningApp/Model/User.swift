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
    let createdAt: Data?
    
    
    init(document: QueryDocumentSnapshot) {
        
        self.uid = document.documentID
        
        let userDic = document.data()
        
        self.email = userDic["email"] as? String ?? ""
        self.username = userDic["username"] as? String ?? ""
        let timestamp = userDic["createdAt"] as? Timestamp
        self.createdAt = timestamp?.dateValue() as? Data
        
        
    }
    
}
