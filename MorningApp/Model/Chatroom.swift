//
//  Chatroom.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/23.
//

import Foundation
import Firebase

class Chatroom: NSObject {
    
    let name: String?
    let text: String?
    let date: Date?
    let stamp: Bool?
    let uid: String?
    
    init(document: QueryDocumentSnapshot) {
        
        let chatDic = document.data()
        
        self.name = chatDic["name"] as? String ?? ""
        self.text = chatDic["text"] as? String  ?? ""
        let timestamp = chatDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        self.stamp = chatDic["stamp"] as? Bool ?? false
        
        
        self.uid = document["uid"] as? String ?? ""
    }
    
}
