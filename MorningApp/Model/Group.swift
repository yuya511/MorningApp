//
//  Group.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/13.
//

import Foundation
import Firebase

class Group: NSObject {
    
    var groupId:String
    var groupName: String?
    var password: String?
    var groupProfileText: String?
    var date: Date?
    var membar = [String]()
    
    init(document: QueryDocumentSnapshot) {
                
        self.groupId = document.documentID
        
        let groupDic = document.data()
        self.password = groupDic["password"] as? String ?? ""
        self.groupName = groupDic["groupName"] as? String ?? ""
        self.membar = groupDic["membar"] as? [String] ?? [""]
        self.groupProfileText = groupDic["groupProfileText"] as? String ?? ""
        let timestamp = groupDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
       
    }
    
    
    init(docu: DocumentSnapshot) {
                
        self.groupId = docu.documentID
        
        let groupDic = docu.data()
        self.password = groupDic?["password"] as? String ?? ""
        self.groupName = groupDic?["groupName"] as? String ?? ""
        self.membar = groupDic?["membar"] as? [String] ?? [""]
        self.groupProfileText = groupDic?["groupProfileText"] as? String ?? ""
        let timestamp = groupDic?["date"] as? Timestamp
        self.date = timestamp?.dateValue()
       
    }

    
    
}
