//
//  Post.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/11/20.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import UIKit

class Post {
    //MARC: Properties
    var name: String
    var theme: String
    var present: String
    var date: String
    var budget: Int
    var photo: UIImage?
    var backImage: UIImage?
    var remainingTime: String
    
    init?(name: String, theme: String, present: String, date: String, budget: Int, photo: UIImage?, backImage: UIImage?, remainingTime: String) {
        self.name = name
        self.theme = theme
        self.present = present
        self.date = date
        self.budget = budget
        self.photo = photo
        self.backImage = backImage
        self.remainingTime = remainingTime
    }
}
