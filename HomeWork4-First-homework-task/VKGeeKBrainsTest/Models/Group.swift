//
//  Group.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit
import RealmSwift

final class Group: Object {
    @objc dynamic var groupName: String = ""
    @objc dynamic var groupLogo: String  = ""
    @objc dynamic var id: Int  = 0
    
    init(groupName: String, groupLogo: String, id: Int) {
        self.groupName = groupName
        self.groupLogo = groupLogo
        self.id = id
    }

    required override init() {
        super.init()
    }
}
