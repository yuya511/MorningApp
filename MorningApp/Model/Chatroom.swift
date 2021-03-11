//
//  Chatroom.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/02/23.
//

import Foundation
import Firebase

class Chatroom: NSObject {
    
    var chatId: String?
    
    var uid: String?
    var name: String?
    var text: String?
    var date: Date?
    var stamp: Bool?
    var supports = [String]()
    var isSupport:Bool = false
    
    init(document: QueryDocumentSnapshot) {
        
        self.chatId = document.documentID
        
        let chatDic = document.data()
        
        self.uid = chatDic["uid"] as? String ?? ""
        
        self.name = chatDic["name"] as? String ?? ""
        self.text = chatDic["text"] as? String  ?? ""
        let timestamp = chatDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        self.stamp = chatDic["stamp"] as? Bool ?? false
        if let supports = chatDic["supports"] as? [String] {
            self.supports = supports
        }
        if let myUid = Auth.auth().currentUser?.uid {
            if self.supports.firstIndex(of: myUid) != nil {
                self.isSupport = true
            }
        }
    }
}
