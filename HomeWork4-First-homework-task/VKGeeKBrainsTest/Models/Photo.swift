//
//  Photo.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit
import RealmSwift

final class Photo: Object {
    @objc dynamic var photo: String = ""
    @objc dynamic var ownerID: String  = ""
    
    init(photo: String, ownerID: String) {
        self.photo = photo
        self.ownerID = ownerID
    }

    required override init() {
        super.init()
    }
}
