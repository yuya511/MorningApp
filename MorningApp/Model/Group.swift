//
//  Group.swift
//  MorningApp
//
//  Created by 山本優也 on 2021/03/13.
//

import Foundation
import Firebase

class Group: NSObject {
    
    var groupName: String?
    
    var uid: String?
    var password: String?
    var date: Date?
    var membar = [String]()
    
    init(document: QueryDocumentSnapshot) {
                
        let groupDic = document.data()
        self.password = groupDic["password"] as? String ?? ""
        self.groupName = groupDic["groupName"] as? String ?? ""
        self.membar = groupDic["membar"] as? [String] ?? [""]
        let timestamp = groupDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
       
    }
}
