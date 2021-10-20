//
//  Friend.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit
import RealmSwift

final class Friend: Object {
    @objc dynamic var userName: String = ""
    @objc dynamic var userAvatar: String  = ""
    @objc dynamic var ownerID: String  = ""
    
    init(userName:String, userAvatar:String, ownerID:String) {
        self.userName = userName
        self.userAvatar = userAvatar
        self.ownerID = ownerID
    }

    required override init() {
        super.init()
    }
}
