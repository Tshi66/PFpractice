//
//  Bank.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/05.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import Foundation
import RealmSwift

class Bank: Object {
    @objc dynamic var id = 0
    @objc dynamic var saving: Int = 0
    @objc dynamic var stack: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
