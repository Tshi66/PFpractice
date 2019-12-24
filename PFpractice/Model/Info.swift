//
//  Info.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/20.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import Foundation
import RealmSwift

class Info: Object {
    
    @objc dynamic var date: String = ""
    @objc dynamic var time: String = ""
    @objc dynamic var repetition: String = ""
    @objc dynamic var enable: Bool = false
    
}
