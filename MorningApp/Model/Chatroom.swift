//
//  Chatroom.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/23.
//

import Foundation
import Firebase

class Chatroom: NSObject {
    
    let id: String
    let name: String?
    let text: String?
    let date: Date?
    let uid: String?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let chatDic = document.data()
        
        self.name = chatDic["name"] as? String ?? ""
        self.text = chatDic["text"] as? String  ?? ""
        let timestamp = chatDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        self.uid = document["uid"] as? String ?? ""
    }
    
}
